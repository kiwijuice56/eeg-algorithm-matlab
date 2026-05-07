function [ratio40, ratio45] = metric_assr_high_over_low_ratios(json_path, channel, Fs)
%METRIC_ASSR_HIGH_OVER_LOW_RATIOS Ratio of ASSR peak power (linear PSD): mean(high trials)/mean(low trials).
%   Same segmentation and pwelch setup as test/app_test_assr.m. Peak = max PSD in band 39-41 Hz (40)
%   and 44-46 Hz (45) per segment.

    json_path = char(json_path);
    ratio40 = NaN;
    ratio45 = NaN;

    try
        eeg_data = read_from_json_file_app(json_path, "assr_listening", "eeg");
        if ~isfield(eeg_data, "eeg") || isempty(eeg_data.eeg.data)
            return;
        end
        eeg_signal = eeg_data.eeg.data(channel, :);

        stimulus_data = read_from_json_file_app(json_path, "assr_listening", "stimulus");
        task_data = read_from_json_file_app(json_path, "assr_listening", "task");

        if ~isfield(stimulus_data, "stimulus_unix_time") || ~isfield(stimulus_data, "stimulus_label")
            return;
        end
        if ~isfield(task_data, "task_start_unix_time") || ~isfield(task_data, "task_end_unix_time")
            return;
        end

        stim_times = app_json_row_vector(stimulus_data.stimulus_unix_time);
        stim_labels = app_json_stimulus_labels(stimulus_data.stimulus_label);
        task_start = app_json_scalar(task_data.task_start_unix_time);
        task_end = app_json_scalar(task_data.task_end_unix_time);

        if isempty(stim_times) || isempty(stim_labels) || ~isfinite(task_start) || ~isfinite(task_end)
            return;
        end
        n_mark = min(numel(stim_times), numel(stim_labels));
        stim_times = stim_times(1:n_mark);
        stim_labels = stim_labels(1:n_mark);

        total_samples = length(eeg_signal);
        if total_samples < 2
            return;
        end
        total_duration = task_end - task_start;
        if total_duration <= 0
            return;
        end
        unix_to_sample = @(t) round((t - task_start) / total_duration * total_samples);

        win = hanning(2048);
        noverlap = 1024;
        nfft = 4096;

        pow40_high = [];
        pow40_low = [];
        pow45_high = [];
        pow45_low = [];

        num_markers = numel(stim_times);
        for i = 1:num_markers
            current_label = char(stim_labels(i));

            if contains(lower(current_label), "rest")
                continue;
            end

            start_idx = unix_to_sample(stim_times(i));
            if i < num_markers
                end_idx = unix_to_sample(stim_times(i + 1)) - 1;
            else
                end_idx = total_samples;
            end
            start_idx = max(1, start_idx);
            end_idx = min(end_idx, total_samples);
            if end_idx < start_idx || (end_idx - start_idx) < 32
                continue;
            end

            segment = eeg_signal(start_idx:end_idx);
            [pxx, f] = pwelch(segment(:), win, noverlap, nfft, Fs);

            p40 = max(pxx(f >= 39 & f <= 41));
            p45 = max(pxx(f >= 44 & f <= 46));
            if isempty(p40) || ~isfinite(p40), p40 = NaN; end
            if isempty(p45) || ~isfinite(p45), p45 = NaN; end

            if contains(current_label, "40_hz_high")
                pow40_high(end + 1) = p40; %#ok<AGROW>
            elseif contains(current_label, "40_hz_low")
                pow40_low(end + 1) = p40; %#ok<AGROW>
            elseif contains(current_label, "45_hz_high")
                pow45_high(end + 1) = p45; %#ok<AGROW>
            elseif contains(current_label, "45_hz_low")
                pow45_low(end + 1) = p45; %#ok<AGROW>
            end
        end

        m40h = mean(pow40_high, "omitnan");
        m40l = mean(pow40_low, "omitnan");
        m45h = mean(pow45_high, "omitnan");
        m45l = mean(pow45_low, "omitnan");

        if isfinite(m40h) && isfinite(m40l) && m40l > 0
            ratio40 = m40h / m40l;
        end
        if isfinite(m45h) && isfinite(m45l) && m45l > 0
            ratio45 = m45h / m45l;
        end
    catch
        ratio40 = NaN;
        ratio45 = NaN;
    end
end
