% Parameters
fS = 10;               % Hz
baseline_seconds = 20; % baseline duration for initial intensity calculation
d = 2.8;               % source-detector distance [cm] for outer sep
DPF = [5.5, 5.5];      % differential pathlength factors (730 nm, 850nm)
epsilon = [400, 1500;  % 730 nm: [HbO, HbR], https://omlc.org/spectra/hemoglobin/moaveni.html
           1060, 800]; % 850 nm: [HbO, HbR]
epsilon_uM = epsilon * 1e-6;

% Load signals
signals = read_from_json_file("data/eric_alfaro/breath_holding_6.json", fS);

input_marker = signals.keyboard_input0.value;

% Units are all in microamps;
% Each signal is proportional to light intensity
outer_left_730  = signals.optics0.value(:);
outer_right_730 = signals.optics1.value(:);
outer_left_850  = signals.optics2.value(:);
outer_right_850 = signals.optics3.value(:);

inner_left_730  = signals.optics4.value(:);
inner_right_730 = signals.optics5.value(:); 
inner_left_850  = signals.optics6.value(:);
inner_right_850 = signals.optics7.value(:); 

t = (0:length(outer_left_730)-1) / fS;

% Convert intensity to optical density (OD) using baseline average
baseline_samples = round(baseline_seconds * fS);
proc_channel = @(sig730, sig850) ...
    ( ...
    -log10([sig730 ./ mean(sig730(1:baseline_samples)), ...
          sig850 ./ mean(sig850(1:baseline_samples))]) ...
    );

OD_left  = proc_channel(outer_left_730,  outer_left_850);
OD_right = proc_channel(outer_right_730, outer_right_850);


% Convert OD to delta OD
deltaOD_left = OD_left - mean(OD_left(1:baseline_samples));
deltaOD_right = OD_right - mean(OD_right(1:baseline_samples)); 

% Apply MBLL
scale = d .* DPF; 
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
title('Outer Left');

subplot(3,1,2);
plot(t, HbO_right, 'r', 'LineWidth',1.2); hold on;
plot(t, HbR_right, 'b', 'LineWidth',1.2);
xlabel('Time (s)'); ylabel('\Delta[Hb] (\muM)');
legend('HbO_2','HbR');
title('Outer Right');

subplot(3,1,3);
plot((0:length(input_marker)-1) / fS, input_marker, 'g');
xlabel('Time (s)');
ylabel('Trigger');
title('Input Trigger');


