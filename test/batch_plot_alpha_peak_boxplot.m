% Batch alpha peak (resting) across three class folders — same PSD method as test/app_test_resting.m
%
% Configure folder paths and display labels for each class, then run this script from the repo root
% (or ensure ../helper is on the MATLAB path).

here = fileparts(mfilename("fullpath"));
addpath(fullfile(here, "..", "helper"));

%% Class folders (raw JSON files per class)
class_one_folder = "data/pilot_young";
class_two_folder = "data/pilot_old_healthy";
class_three_folder = "data/pilot_old_unhealthy";

%% Text labels used on the plot (x-axis)
class_one_label = "Healthy young users";
class_two_label = "Healthy geriatric users";
class_three_label = "Cognitively impaired users";

%% Analysis parameters (match test/app_test_resting.m)
Fs = 256;
channel = 1;

paths1 = list_json_files_in_folder(class_one_folder);
paths2 = list_json_files_in_folder(class_two_folder);
paths3 = list_json_files_in_folder(class_three_folder);

v1 = local_collect(paths1, channel, Fs);
v2 = local_collect(paths2, channel, Fs);
v3 = local_collect(paths3, channel, Fs);

figure;
plot_three_class_boxplot_with_dots( ...
    {v1, v2, v3}, ...
    [class_one_label, class_two_label, class_three_label], ...
    "Resting alpha peak frequency (Hz)", ...
    "Alpha peak (Hz)");

function v = local_collect(paths, channel, Fs)
    v = [];
    for i = 1:numel(paths)
        pk = metric_alpha_peak_hz_resting(paths(i), channel, Fs);
        if isfinite(pk)
            v(end + 1, 1) = pk; %#ok<AGROW>
        end
    end
end
