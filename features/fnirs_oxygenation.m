% Parameters
fS = 64;               % Hz
baseline_seconds = 20; % baseline duration for initial intensity calculation
d = 2.8;               % source-detector distance [cm] for outer sep
DPF = [5.5, 5.5];      % differential pathlength factors (730 nm, 850nm)
hpf_hz = 0.01;         % band-pass lower cutoff [Hz]
lpf_hz = 0.2;          % band-pass upper cutoff [Hz], attenuates cardiac (~1-1.5 Hz)
epsilon = [400, 1500;  % 730 nm: [HbO, HbR], https://omlc.org/spectra/hemoglobin/moaveni.html
           1060, 800]; % 850 nm: [HbO, HbR]
epsilon_uM = epsilon * 1e-6;
data_path = "data/eric_alfaro/breath_holding_3.json";

% Load signals
signals = read_from_json_file_raw(data_path, "optics");

% Units are all in microamps;
% Each signal is proportional to light intensity
outer_left_730  = signals.optics.data(1,:)';
outer_right_730 = signals.optics.data(2,:)';
outer_left_850  = signals.optics.data(3,:)';
outer_right_850 = signals.optics.data(4,:)';

inner_left_730  = signals.optics.data(5,:)';
inner_right_730 = signals.optics.data(6,:)';
inner_left_850  = signals.optics.data(7,:)';
inner_right_850 = signals.optics.data(8,:)';

t = (0:length(outer_left_730) - 1) / fS;

% Convert intensity to optical density (OD) using baseline average
baseline_samples = round(baseline_seconds * fS);
baseline_samples = min(max(baseline_samples, 1), length(outer_left_730));
proc_channel = @(sig730, sig850) ...
    ( ...
    -log10([sig730 ./ mean(sig730(1:baseline_samples)), ...
          sig850 ./ mean(sig850(1:baseline_samples))]) ...
    );

OD_left  = proc_channel(outer_left_730,  outer_left_850);
OD_right = proc_channel(outer_right_730, outer_right_850);

% Convert OD to delta OD
deltaOD_left = OD_left - mean(OD_left(1:baseline_samples, :), 1);
deltaOD_right = OD_right - mean(OD_right(1:baseline_samples, :), 1);

% Standard fNIRS denoising step: band-pass filtering to suppress heartbeat and slow drift.
% Sources:
% - https://www.mdpi.com/1999-4893/11/5/67
% - https://pmc.ncbi.nlm.nih.gov/articles/PMC6336925/
if lpf_hz >= (fS / 2)
    error('lpf_hz must be less than Nyquist frequency (fS/2).');
end
[b_bp, a_bp] = butter(3, [hpf_hz, lpf_hz] / (fS / 2), 'bandpass');
deltaOD_left = filtfilt(b_bp, a_bp, deltaOD_left);
deltaOD_right = filtfilt(b_bp, a_bp, deltaOD_right);

% Apply MBLL
scale = d .* DPF(:); % wavelength-specific pathlength: [L730; L850]
E = epsilon_uM .* scale;
pinvE = pinv(E);

C_left  = (pinvE * deltaOD_left')';   % delta[HbO, HbR] for left outer
C_right = (pinvE * deltaOD_right')';  % delta[HbO, HbR] for right outer

HbO_left  = C_left(:,1);  HbR_left  = C_left(:,2);
HbO_right = C_right(:,1); HbR_right = C_right(:,2);

% Plots
figure;
subplot(3,1,1);
plot(t, HbO_left, 'r', 'LineWidth',1.2); hold on;
plot(t, HbR_left, 'b', 'LineWidth',1.2);
xlabel('Time (s)'); ylabel('\Delta[Hb] (\muM)');
legend('HbO_2','HbR');
title('Left');

subplot(3,1,2);
plot(t, HbO_right, 'r', 'LineWidth',1.2); hold on;
plot(t, HbR_right, 'b', 'LineWidth',1.2);
xlabel('Time (s)'); ylabel('\Delta[Hb] (\muM)');
legend('HbO_2','HbR');
title('Right');

subplot(3,1,3);
markers = read_from_json_file_raw(data_path, "keyboard_input");
marker_signal = markers.keyboard_input.data';
t = (0:length(marker_signal) - 1) / length(marker_signal) * t(end);
plot(t, marker_signal);

