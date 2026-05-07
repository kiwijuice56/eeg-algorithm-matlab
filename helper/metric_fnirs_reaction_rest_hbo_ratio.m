function ratio = metric_fnirs_reaction_rest_hbo_ratio(json_path, varargin)
%METRIC_FNIRS_REACTION_REST_HBO_RATIO Mean HbO (first 10 s, outer L+R average) reaction / same metric resting.
%   Processing matches features/fnirs_oxygenation.m (MBLL on outer channels, band-pass on deltaOD).

    json_path = char(json_path);
    p = inputParser;
    addParameter(p, "fS", 64);
    addParameter(p, "baseline_seconds", 20);
    addParameter(p, "d", 2.8);
    addParameter(p, "DPF", [5.5, 5.5]);
    addParameter(p, "epsilon", [400, 1500; 1060, 800]);
    addParameter(p, "hpf_hz", 0.01);
    addParameter(p, "lpf_hz", 0.2);
    addParameter(p, "avg_seconds", 10);
    parse(p, varargin{:});
    fS = p.Results.fS;
    baseline_seconds = p.Results.baseline_seconds;
    d = p.Results.d;
    DPF = p.Results.DPF(:);
    epsilon = p.Results.epsilon;
    hpf_hz = p.Results.hpf_hz;
    lpf_hz = p.Results.lpf_hz;
    avg_seconds = p.Results.avg_seconds;

    ratio = NaN;

    if lpf_hz >= (fS / 2)
        return;
    end
    [b_bp, a_bp] = butter(3, [hpf_hz, lpf_hz] / (fS / 2), 'bandpass');
    epsilon_uM = epsilon * 1e-6;
    scale = d .* DPF;
    E = epsilon_uM .* scale;
    pinvE = pinv(E);

    try
        m_rest = local_mean_hbo_first_seconds(json_path, "no_stimulus", fS, baseline_seconds, ...
            pinvE, b_bp, a_bp, avg_seconds);
        m_react = local_mean_hbo_first_seconds(json_path, "reaction", fS, baseline_seconds, ...
            pinvE, b_bp, a_bp, avg_seconds);
        if isfinite(m_rest) && isfinite(m_react) && abs(m_rest) > eps
            ratio = m_react / m_rest;
        end
    catch
        ratio = NaN;
    end
end

function m = local_mean_hbo_first_seconds(json_path, task, fS, baseline_seconds, pinvE, b_bp, a_bp, avg_seconds)
    m = NaN;
    signals = read_from_json_file_app(json_path, task, "optics");
    if ~isfield(signals, "optics") || isempty(signals.optics.data)
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

    deltaOD_left = filtfilt(b_bp, a_bp, deltaOD_left);
    deltaOD_right = filtfilt(b_bp, a_bp, deltaOD_right);

    C_left = (pinvE * deltaOD_left')';
    C_right = (pinvE * deltaOD_right')';
    HbO_left = C_left(:, 1);
    HbO_right = C_right(:, 1);

    n_avg = min(round(avg_seconds * fS), n_samples);
    combo = (HbO_left(1:n_avg) + HbO_right(1:n_avg)) / 2;
    m = mean(combo, 'omitnan');
end
