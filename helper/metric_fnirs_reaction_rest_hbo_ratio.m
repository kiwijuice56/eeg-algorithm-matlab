function ratio = metric_fnirs_reaction_rest_hbo_ratio(json_path, varargin)
%METRIC_FNIRS_REACTION_REST_HBO_RATIO Mean HbO (first 10 s, outer L+R average) reaction / same metric resting.
%   Uses helper/fnirs_extract_hb_timeseries.m for MBLL processing.

    p = inputParser;
    addParameter(p, 'fS', 64);
    addParameter(p, 'baseline_seconds', 20);
    addParameter(p, 'd', 2.8);
    addParameter(p, 'DPF', [5.5, 5.5]);
    addParameter(p, 'epsilon', [400, 1500; 1060, 800]);
    addParameter(p, 'hpf_hz', 0.01);
    addParameter(p, 'lpf_hz', 0.2);
    addParameter(p, 'apply_bandpass', true);
    addParameter(p, 'avg_seconds', 10);
    parse(p, varargin{:});

    opts = {'fS', p.Results.fS, ...
        'baseline_seconds', p.Results.baseline_seconds, ...
        'd', p.Results.d, ...
        'DPF', p.Results.DPF, ...
        'epsilon', p.Results.epsilon, ...
        'hpf_hz', p.Results.hpf_hz, ...
        'lpf_hz', p.Results.lpf_hz, ...
        'apply_bandpass', p.Results.apply_bandpass};

    ratio = NaN;

    hb_rest = fnirs_extract_hb_timeseries(json_path, 'no_stimulus', opts{:});
    hb_react = fnirs_extract_hb_timeseries(json_path, 'reaction', opts{:});
    if ~hb_rest.ok || ~hb_react.ok
        return;
    end

    m_rest = fnirs_mean_hbo_lr_first_seconds(hb_rest, p.Results.avg_seconds);
    m_react = fnirs_mean_hbo_lr_first_seconds(hb_react, p.Results.avg_seconds);
    if isfinite(m_rest) && isfinite(m_react) && abs(m_rest) > eps
        ratio = m_react / m_rest;
    end
end

function m = fnirs_mean_hbo_lr_first_seconds(hb, avg_seconds)
    n_avg = min(round(avg_seconds * hb.fS), hb.n_samples);
    combo = (hb.HbO_left(1:n_avg) + hb.HbO_right(1:n_avg)) / 2;
    m = mean(combo, 'omitnan');
end
