function peak_hz = metric_alpha_peak_hz_resting(json_path, channel, Fs)
%METRIC_ALPHA_PEAK_HZ_RESTING Alpha peak (Hz) from no_stimulus EEG, same method as test/app_test_resting.m.
    json_path = char(json_path);
    peak_hz = NaN;
    try
        signals = read_from_json_file_app(json_path, "no_stimulus", "eeg");
        if ~isfield(signals, "eeg") || isempty(signals.eeg.data)
            return;
        end
        sig = signals.eeg.data(channel, :);
        if isempty(sig) || all(~isfinite(sig))
            return;
        end

        win = hanning(2048);
        noverlap = 1024;
        nfft = 4096;
        [pxx, f] = pwelch(sig(:), win, noverlap, nfft, Fs);

        smooth_bins = 3;
        pxx_smooth = movmean(pxx, smooth_bins);

        alpha_mask = f >= 7 & f <= 13;
        f_alpha = f(alpha_mask);
        pxx_alpha = pxx_smooth(alpha_mask);
        if isempty(pxx_alpha) || all(~isfinite(pxx_alpha))
            return;
        end
        [~, idx] = max(pxx_alpha);
        peak_hz = double(f_alpha(idx));
    catch
        peak_hz = NaN;
    end
end
