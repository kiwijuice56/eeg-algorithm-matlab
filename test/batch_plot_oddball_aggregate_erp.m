% Aggregate oddball ERPs across all recordings in one class folder.
% Uses the same streams as test/app_test_oddball.m (notch_filtered_eeg, stimulus, task) and the same
% epoching / baseline correction as test/app_test_oddball_erp.m, then pools rare vs common epochs
% across ALL files and plots mean ERPs.
%
% Full-length EEG per file: 0.5–90 Hz band-pass and 60 Hz notch (filtfilt), then the first and last
% stim_edge_exclude stimulus onsets are excluded from epoching so edge transients do not enter counts.

here = fileparts(mfilename("fullpath"));
addpath(fullfile(here, "..", "helper"));

%% One class: folder of raw JSON files + plot title label
class_folder = "data/pilot_young";
class_display_name = "Healthy young users";

%% Epoch / channel parameters (match test/app_test_oddball_erp.m)
Fs = 256;
channel = 1;
pre_stim_ms = 200;
post_stim_ms = 800;
%% Full-signal filters (applied before epoching)
bandpass_hz = [0.5, 90];
notch_hz = 60;
%% Exclude this many stimulus onsets from the start and end of each recording (after align)
stim_edge_exclude = 3;

pre_samples = round(pre_stim_ms / 1000 * Fs);
post_samples = round(post_stim_ms / 1000 * Fs);
epoch_samples = pre_samples + post_samples;
t_epoch = linspace(-pre_stim_ms, post_stim_ms, epoch_samples);

paths = list_json_files_in_folder(class_folder);

common_all = [];
rare_all = [];

for i = 1:numel(paths)
    [C, R] = local_extract_epochs(char(paths(i)), Fs, channel, pre_samples, post_samples, ...
        bandpass_hz, notch_hz, stim_edge_exclude);
    if ~isempty(C)
        common_all = [common_all; C]; %#ok<AGROW>
    end
    if ~isempty(R)
        rare_all = [rare_all; R]; %#ok<AGROW>
    end
end

if isempty(common_all) && isempty(rare_all)
    warning("No valid epochs in folder: %s", char(class_folder));
    return;
end

if ~isempty(common_all)
    common_erp = mean(common_all, 1, 'omitnan');
else
    common_erp = [];
end
if ~isempty(rare_all)
    rare_erp = mean(rare_all, 1, 'omitnan');
else
    rare_erp = [];
end

figure;
hold on;
if ~isempty(common_all)
    plot(t_epoch, common_erp, "Color", [0 0.5 0], "LineWidth", 2, ...
        "DisplayName", sprintf("Common (n=%d epochs)", size(common_all, 1)));
end
if ~isempty(rare_all)
    plot(t_epoch, rare_erp, "Color", [0.5 0 0.5], "LineWidth", 2, ...
        "DisplayName", sprintf("Rare (n=%d epochs)", size(rare_all, 1)));
end
xline(0, "k--", "Stimulus onset", "LineWidth", 1.2, "HandleVisibility", "off");
xlabel("Time (ms)");
ylabel("EEG amplitude (baseline corrected, \muV)");
title(sprintf("Oddball EEG pulses pooled (%s)", class_display_name), "Interpreter", "none");
legend("Location", "best");
grid on;
hold off;

function [common_epochs, rare_epochs] = local_extract_epochs(json_path, Fs, channel, pre_samples, post_samples, ...
        bandpass_hz, notch_hz, stim_edge_exclude)
    common_epochs = [];
    rare_epochs = [];

    try
        eeg_data = read_from_json_file_app(json_path, "oddball", "notch_filtered_eeg");
        if ~isfield(eeg_data, "notch_filtered_eeg") || isempty(eeg_data.notch_filtered_eeg.data)
            return;
        end
        eeg_signal = double(eeg_data.notch_filtered_eeg.data(channel, :));
        eeg_signal = eeg_signal(:)';

        % Band-pass entire trial EEG, then notch line noise (zero-phase).
        nyq = Fs / 2;
        bp = bandpass_hz / nyq;
        bp(1) = max(bp(1), 1.5 / nyq);
        bp(2) = min(bp(2), 1 - 1.5 / nyq);
        if bp(1) >= bp(2)
            return;
        end
        [b_bp, a_bp] = butter(4, bp, 'bandpass');
        min_len = 3 * max(numel(b_bp), numel(a_bp)) + 32;
        if numel(eeg_signal) < min_len
            warning("batch_plot_oddball_aggregate_erp:SkipShort %s: EEG length %d < min %d for filtfilt", ...
                json_path, numel(eeg_signal), min_len);
            return;
        end
        eeg_signal = filtfilt(b_bp, a_bp, eeg_signal);

        % Narrow band-stop around line frequency (iirnotch second arg is bandwidth, not Q — avoid misuse).
        notch_halfwidth_hz = 3;
        f_lo = max((notch_hz - notch_halfwidth_hz) / nyq, bp(1) * 1.001);
        f_hi = min((notch_hz + notch_halfwidth_hz) / nyq, bp(2) * 0.999);
        if f_lo < f_hi
            [b_n, a_n] = butter(4, [f_lo, f_hi], 'stop');
            eeg_signal = filtfilt(b_n, a_n, eeg_signal);
        end

        stimulus_data = read_from_json_file_app(json_path, "oddball", "stimulus");
        task_data = read_from_json_file_app(json_path, "oddball", "task");

        if ~isfield(stimulus_data, "stimulus_unix_time") || ~isfield(stimulus_data, "stimulus_label")
            return;
        end
        if ~isfield(task_data, "task_start_unix_time") || ~isfield(task_data, "task_end_unix_time")
            return;
        end

        stimulus_times = app_json_row_vector(stimulus_data.stimulus_unix_time);
        stimulus_labels = app_json_stimulus_labels(stimulus_data.stimulus_label);
        task_start_time = app_json_scalar(task_data.task_start_unix_time);
        task_end_time = app_json_scalar(task_data.task_end_unix_time);

        if isempty(stimulus_times) || isempty(stimulus_labels) || ~isfinite(task_start_time) || ~isfinite(task_end_time)
            return;
        end

        nSamples = numel(eeg_signal);
        t = linspace(task_start_time, task_end_time, nSamples);

        n_stim = min(numel(stimulus_times), numel(stimulus_labels));
        stimulus_times = stimulus_times(1:n_stim);
        stimulus_labels = stimulus_labels(1:n_stim);

        n_edge = max(0, round(stim_edge_exclude));
        if numel(stimulus_times) <= 2 * n_edge
            return;
        end
        stimulus_times = stimulus_times(n_edge + 1:end - n_edge);
        stimulus_labels = stimulus_labels(n_edge + 1:end - n_edge);

        for k = 1:numel(stimulus_times)
            stim_t = stimulus_times(k);
            lbl = char(stimulus_labels(k));

            [~, stim_idx] = min(abs(t - stim_t));

            idx_start = stim_idx - pre_samples;
            idx_end = stim_idx + post_samples - 1;

            if idx_start < 1 || idx_end > nSamples
                continue;
            end

            epoch = eeg_signal(idx_start:idx_end);
            epoch = epoch - mean(epoch(1:pre_samples));

            if strcmpi(strtrim(lbl), "rare")
                rare_epochs(end + 1, :) = epoch; %#ok<AGROW>
            else
                common_epochs(end + 1, :) = epoch; %#ok<AGROW>
            end
        end
    catch ME
        common_epochs = [];
        rare_epochs = [];
        warning("batch_plot_oddball_aggregate_erp:EpochFail %s: %s", json_path, ME.message);
    end
end
