function out = fnirs_extract_hb_timeseries(json_path, task, varargin)
%FNIRS_EXTRACT_HB_TIMESERIES Delta HbO/HbR time series from Muse outer optics (MBLL).
%
%   out = fnirs_extract_hb_timeseries(json_path, task)
%   out = fnirs_extract_hb_timeseries(json_path, task, Name, Value, ...)
%
%   Name-value parameters (defaults match features/fnirs_oxygenation.m):
%     fS, baseline_seconds, d, DPF, epsilon, hpf_hz, lpf_hz, apply_bandpass
%
%   Output struct fields:
%     ok, HbO_left, HbR_left, HbO_right, HbR_right, n_samples, fS

    json_path = char(json_path);
    task = char(task);

    p = inputParser;
    addParameter(p, 'fS', 64);
    addParameter(p, 'baseline_seconds', 20);
    addParameter(p, 'd', 2.8);
    addParameter(p, 'DPF', [5.5, 5.5]);
    addParameter(p, 'epsilon', [400, 1500; 1060, 800]); % rows: 730, 850 nm; cols: HbO, HbR
    addParameter(p, 'hpf_hz', 0.01);
    addParameter(p, 'lpf_hz', 0.2);
    addParameter(p, 'apply_bandpass', true);
    parse(p, varargin{:});

    fS = p.Results.fS;
    baseline_seconds = p.Results.baseline_seconds;
    d = p.Results.d;
    DPF = p.Results.DPF(:);
    epsilon = p.Results.epsilon;
    hpf_hz = p.Results.hpf_hz;
    lpf_hz = p.Results.lpf_hz;
    apply_bandpass = p.Results.apply_bandpass;

    out = struct('ok', false, 'HbO_left', [], 'HbR_left', [], ...
        'HbO_right', [], 'HbR_right', [], 'n_samples', 0, 'fS', fS);

    try
        signals = read_from_json_file_app(json_path, task, 'optics');
        if ~isfield(signals, 'optics') || isempty(signals.optics.data)
            return;
        end

        outer_left_730 = signals.optics.data(1, :)';
        outer_right_730 = signals.optics.data(2, :)';
        outer_left_850 = signals.optics.data(3, :)';
        outer_right_850 = signals.optics.data(4, :)';

        n_samples = length(outer_left_730);
        if n_samples < 8
            return;
        end

        baseline_samples = round(baseline_seconds * fS);
        baseline_samples = min(max(baseline_samples, 1), n_samples);

        proc_channel = @(sig730, sig850) ( ...
            -log10([sig730 ./ mean(sig730(1:baseline_samples)), ...
            sig850 ./ mean(sig850(1:baseline_samples))]) ...
            );

        OD_left = proc_channel(outer_left_730, outer_left_850);
        OD_right = proc_channel(outer_right_730, outer_right_850);

        deltaOD_left = OD_left - mean(OD_left(1:baseline_samples, :), 1);
        deltaOD_right = OD_right - mean(OD_right(1:baseline_samples, :), 1);

        % Band-pass on deltaOD suppresses heartbeat and slow drift.
        % Sources:
        % - https://www.mdpi.com/1999-4893/11/5/67
        % - https://pmc.ncbi.nlm.nih.gov/articles/PMC6336925/
        if apply_bandpass
            if lpf_hz >= (fS / 2)
                return;
            end
            [b_bp, a_bp] = butter(3, [hpf_hz, lpf_hz] / (fS / 2), 'bandpass');
            deltaOD_left = filtfilt(b_bp, a_bp, deltaOD_left);
            deltaOD_right = filtfilt(b_bp, a_bp, deltaOD_right);
        end

        epsilon_uM = epsilon * 1e-6;
        scale = d .* DPF;
        E = epsilon_uM .* scale;
        pinvE = pinv(E);

        C_left = (pinvE * deltaOD_left')';
        C_right = (pinvE * deltaOD_right')';

        out.HbO_left = C_left(:, 1);
        out.HbR_left = C_left(:, 2);
        out.HbO_right = C_right(:, 1);
        out.HbR_right = C_right(:, 2);
        out.n_samples = n_samples;
        out.fS = fS;
        out.ok = true;
    catch
        out.ok = false;
    end
end
