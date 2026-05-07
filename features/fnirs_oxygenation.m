here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, '..', 'helper'));

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
data_path = "data/pilot_young/9aaadb90-9d64-44d0-8866-429b18498898.json";
tasks = ["no_stimulus", "assr_listening", "oddball", "reaction"];
task_titles = ["No Stimulus", "ASSR Listening", "Oddball", "Reaction"];

if lpf_hz >= (fS / 2)
    error('lpf_hz must be less than Nyquist frequency (fS/2).');
end
[b_bp, a_bp] = butter(3, [hpf_hz, lpf_hz] / (fS / 2), 'bandpass');

% MBLL solve matrix
scale = d .* DPF(:); % wavelength-specific pathlength: [L730; L850]
E = epsilon_uM .* scale;
pinvE = pinv(E);

% First pass: process each task and find minimum duration (crop all plots to this length)
results = struct();
min_samples = inf;

for i = 1:numel(tasks)
    task = tasks(i);
    signals = read_from_json_file_app(data_path, task, "optics");

    outer_left_730  = signals.optics.data(1,:)';
    outer_right_730 = signals.optics.data(2,:)';
    outer_left_850  = signals.optics.data(3,:)';
    outer_right_850 = signals.optics.data(4,:)';

    n_samples = length(outer_left_730);
    min_samples = min(min_samples, n_samples);

    baseline_samples = round(baseline_seconds * fS);
    baseline_samples = min(max(baseline_samples, 1), n_samples);

    proc_channel = @(sig730, sig850) ...
        ( ...
        -log10([sig730 ./ mean(sig730(1:baseline_samples)), ...
              sig850 ./ mean(sig850(1:baseline_samples))]) ...
        );

    OD_left  = proc_channel(outer_left_730,  outer_left_850);
    OD_right = proc_channel(outer_right_730, outer_right_850);

    deltaOD_left = OD_left - mean(OD_left(1:baseline_samples, :), 1);
    deltaOD_right = OD_right - mean(OD_right(1:baseline_samples, :), 1);

    % Standard fNIRS denoising step: band-pass filtering to suppress heartbeat and slow drift.
    % Sources:
    % - https://www.mdpi.com/1999-4893/11/5/67
    % - https://pmc.ncbi.nlm.nih.gov/articles/PMC6336925/
    deltaOD_left = filtfilt(b_bp, a_bp, deltaOD_left);
    deltaOD_right = filtfilt(b_bp, a_bp, deltaOD_right);

    C_left  = (pinvE * deltaOD_left')';   % delta[HbO, HbR] for left outer
    C_right = (pinvE * deltaOD_right')';  % delta[HbO, HbR] for right outer

    task_data = read_from_json_file_app(data_path, task, "task");
    stimulus_data = read_from_json_file_app(data_path, task, "stimulus");

    task_start_time = NaN;
    task_end_time = NaN;
    if isfield(task_data, "task_start_unix_time")
        task_start_time = app_json_scalar(task_data.task_start_unix_time);
    end
    if isfield(task_data, "task_end_unix_time")
        task_end_time = app_json_scalar(task_data.task_end_unix_time);
    end

    stimulus_rel_sec = local_stimulus_times_sec(stimulus_data, task, task_start_time, task_end_time, n_samples, fS);

    results(i).HbO_left = C_left(:,1);
    results(i).HbR_left = C_left(:,2);
    results(i).HbO_right = C_right(:,1);
    results(i).HbR_right = C_right(:,2);
    results(i).stimulus_rel_sec = stimulus_rel_sec(:);
    results(i).n_samples = n_samples;
end

if ~isfinite(min_samples) || min_samples < 1
    error("No valid optics length across tasks.");
end

% Plot as 2x2 components; each component has two stacked plots (left/right)
figure;
h_hbo_legend = [];
h_hbr_legend = [];
h_stim_legend = [];
for i = 1:numel(tasks)
    row_offset = 2 * floor((i - 1) / 2);
    col = mod(i - 1, 2) + 1;
    top_idx = row_offset * 2 + col;
    bottom_idx = top_idx + 2;

    t = (0:min_samples - 1) / fS;
    HbO_left = results(i).HbO_left(1:min_samples);
    HbR_left = results(i).HbR_left(1:min_samples);
    HbO_right = results(i).HbO_right(1:min_samples);
    HbR_right = results(i).HbR_right(1:min_samples);
    stim_t = results(i).stimulus_rel_sec;
    stim_t = stim_t(stim_t >= 0 & stim_t <= t(end));

    ax_top = subplot(4,2,top_idx);
    h_hbo = plot(t, HbO_left, 'r', 'LineWidth', 1.2); hold on;
    h_hbr = plot(t, HbR_left, 'b', 'LineWidth', 1.2);
    h_stim = gobjects(0);
    for k = 1:numel(stim_t)
        h_stim(end+1) = xline(stim_t(k), 'g-', 'LineWidth', 0.8); %#ok<SAGROW>
    end
    ylabel('\Delta[Hb] (\muM)');
    title(task_titles(i) + " - Left");
    if isempty(h_hbo_legend)
        h_hbo_legend = h_hbo;
        h_hbr_legend = h_hbr;
        if ~isempty(h_stim)
            h_stim_legend = h_stim(1);
        end
    end
    xlim([0 t(end)]);

    ax_bottom = subplot(4,2,bottom_idx);
    plot(t, HbO_right, 'r', 'LineWidth', 1.2); hold on;
    plot(t, HbR_right, 'b', 'LineWidth', 1.2);
    for k = 1:numel(stim_t)
        xline(stim_t(k), 'g-', 'LineWidth', 0.8);
    end
    ylabel('\Delta[Hb] (\muM)');
    xlabel('Time (s)');
    title(task_titles(i) + " - Right");
    xlim([0 t(end)]);

    % Keep y-limits aligned within each task component (left/right).
    yl = [min([ax_top.YLim(1), ax_bottom.YLim(1)]), max([ax_top.YLim(2), ax_bottom.YLim(2)])];
    ax_top.YLim = yl;
    ax_bottom.YLim = yl;
end

if ~isempty(h_stim_legend)
    lgd = legend([h_hbo_legend, h_hbr_legend, h_stim_legend], {'HbO_2', 'HbR', 'Stimulus'});
else
    lgd = legend([h_hbo_legend, h_hbr_legend], {'HbO_2', 'HbR'});
end
set(lgd, 'Units', 'normalized', 'Position', [0.40, 0.01, 0.2, 0.03], 'Orientation', 'horizontal');

function stim_rel = local_stimulus_times_sec(stimulus_data, task, task_start_time, task_end_time, n_samples, fS)
% Stimulus times relative to task start (s). For oddball, only deviant / rare tones (README: rare vs common).
    stim_rel = [];
    if ~isfield(stimulus_data, "stimulus_unix_time")
        return;
    end
    stim_unix = app_json_row_vector(stimulus_data.stimulus_unix_time);
    if isempty(stim_unix)
        return;
    end
    if isfinite(task_start_time)
        rel_all = stim_unix(:) - task_start_time;
    elseif isfinite(task_end_time)
        rel_all = stim_unix(:) - (task_end_time - n_samples / fS);
    else
        return;
    end

    if strcmp(task, "oddball") && isfield(stimulus_data, "stimulus_label")
        labels = app_json_stimulus_labels(stimulus_data.stimulus_label);
        n = min(numel(rel_all), numel(labels));
        rel_all = rel_all(1:n);
        labels = labels(1:n);
        mask = false(n, 1);
        for k = 1:n
            mask(k) = local_is_oddball_deviant_label(labels(k));
        end
        stim_rel = rel_all(mask);
    else
        stim_rel = rel_all(:);
    end
end

function tf = local_is_oddball_deviant_label(lbl)
    s = lower(strtrim(char(string(lbl))));
    tf = strcmp(s, "rare") || strcmp(s, "deviant") || strcmp(s, "oddball");
end

