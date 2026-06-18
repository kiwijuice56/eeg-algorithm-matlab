function out = fnirs_decompose_emd(x, varargin)
%FNIRS_DECOMPOSE_EMD Empirical mode decomposition of a single fNIRS time series.
%
%   Requires Signal Processing Toolbox: emd()
%   https://www.mathworks.com/help/signal/ref/emd.html
%
%   out = fnirs_decompose_emd(x)
%   out = fnirs_decompose_emd(x, 'MaxNumIMF', 8, 'Interpolation', 'pchip')
%
%   Output fields: ok, imf (n_samples x n_imf), residual, n_imf, labels

    out = struct('ok', false, 'imf', [], 'residual', [], 'n_imf', 0, 'labels', {{}});

    if ~exist('emd', 'file')
        error('fnirs_decompose_emd:NoEMD', ...
            'Built-in emd() not found. Install Signal Processing Toolbox.');
    end

    p = inputParser;
    addParameter(p, 'MaxNumIMF', []);
    addParameter(p, 'Interpolation', 'pchip'); % recommended for non-smooth fNIRS traces
    parse(p, varargin{:});

    x = double(x(:));
    if numel(x) < 16 || all(~isfinite(x))
        return;
    end
    if any(~isfinite(x))
        x = fillmissing(x, 'linear', 'EndValues', 'nearest');
    end

    emd_args = {'Interpolation', p.Results.Interpolation};
    if ~isempty(p.Results.MaxNumIMF)
        emd_args = [emd_args, {'MaxNumIMF', p.Results.MaxNumIMF}];
    end

    try
        [imf, residual] = emd(x, emd_args{:});
        out.imf = imf;
        out.residual = residual;
        out.n_imf = size(imf, 2);
        out.labels = arrayfun(@(k) sprintf('IMF %d', k), 1:out.n_imf, 'UniformOutput', false);
        out.ok = true;
    catch ME
        error('fnirs_decompose_emd:Failed', 'emd() failed: %s', ME.message);
    end
end
