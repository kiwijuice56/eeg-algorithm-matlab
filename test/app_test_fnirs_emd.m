% Decompose a single Hb time series with built-in EMD (Signal Processing Toolbox emd).
% Top: band-pass reference. Below: each intrinsic mode function (IMF) + residual.
% IMFs are ordered high-frequency → low-frequency; early IMFs often carry cardiac/respiratory content.

here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, '..', 'helper'));

%% Recording
data_path = "data/pilot_young/9aaadb90-9d64-44d0-8866-429b18498898.json";
task = "reaction";

%% Channel: HbO_left | HbR_left | HbO_right | HbR_right
plot_channel = "HbO_left";

%% EMD options (see help emd)
max_num_imf = [];        % [] = let emd decide; or e.g. 8 to cap IMF count
emd_interpolation = "pchip";

%% Processing parameters (shared with features/fnirs_oxygenation.m)
fS = 64;
baseline_seconds = 20;
d = 2.8;
DPF = [5.5, 5.5];
epsilon = [400, 1500; 1060, 800];
hpf_hz = 0.01;
lpf_hz = 0.2;

common_opts = {'fS', fS, 'baseline_seconds', baseline_seconds, 'd', d, ...
    'DPF', DPF, 'epsilon', epsilon, 'hpf_hz', hpf_hz, 'lpf_hz', lpf_hz};

hb_bp = fnirs_extract_hb_timeseries(data_path, task, common_opts{:}, 'apply_bandpass', true);
hb_raw = fnirs_extract_hb_timeseries(data_path, task, common_opts{:}, 'apply_bandpass', false);

if ~hb_bp.ok || ~hb_raw.ok
    error('fNIRS extraction failed for %s (%s)', task, data_path);
end

valid_channels = ["HbO_left", "HbR_left", "HbO_right", "HbR_right"];
if ~any(strcmp(plot_channel, valid_channels))
    error('plot_channel must be one of: HbO_left, HbR_left, HbO_right, HbR_right');
end

ref_signal = hb_bp.(plot_channel);
emd_input = hb_raw.(plot_channel);
t = (0:hb_bp.n_samples - 1)' / fS;

emd_opts = {'Interpolation', emd_interpolation};
if ~isempty(max_num_imf)
    emd_opts = [emd_opts, {'MaxNumIMF', max_num_imf}];
end
emd_out = fnirs_decompose_emd(emd_input, emd_opts{:});

n_imf = emd_out.n_imf;
n_rows = 1 + n_imf + 1; % reference + IMFs + residual

figure('Name', sprintf('fNIRS EMD — %s (%s)', plot_channel, task));
ax = gobjects(n_rows, 1);

ax(1) = subplot(n_rows, 1, 1);
plot(t, ref_signal, 'r', 'LineWidth', 1.2);
ylabel('\Delta[Hb] (\muM)');
title(sprintf('%s — band-pass reference', plot_channel), 'Interpreter', 'none');
grid on;
xlim([t(1), t(end)]);

for k = 1:n_imf
    ax(k + 1) = subplot(n_rows, 1, k + 1);
    plot(t, emd_out.imf(:, k), 'Color', [0.2 0.45 0.75], 'LineWidth', 1.2);
    ylabel('AU');
    title(emd_out.labels{k}, 'Interpreter', 'none');
    grid on;
    xlim([t(1), t(end)]);
end

ax(end) = subplot(n_rows, 1, n_rows);
plot(t, emd_out.residual, 'Color', [0.45 0.45 0.45], 'LineWidth', 1.2);
ylabel('AU');
title('Residual (trend)', 'Interpreter', 'none');
grid on;
xlim([t(1), t(end)]);

xlabel(ax(end), 'Time (s)');
linkaxes(ax, 'x');
sgtitle(sprintf('fNIRS EMD: %s (%s, no band-pass input)', plot_channel, task), 'Interpreter', 'none');
