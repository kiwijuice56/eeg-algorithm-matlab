% Batch ASSR high/low peak-power ratios — segmentation + pwelch as test/app_test_assr.m
% Top: mean(40 Hz high trial peak) / mean(40 Hz low trial peak) in linear PSD (39–41 Hz band max)
% Bottom: same for 45 Hz (44–46 Hz band max)

here = fileparts(mfilename("fullpath"));
addpath(fullfile(here, "..", "helper"));

%% Class folders (raw JSON files per class)
class_one_folder = "data/pilot_young_combined";
class_two_folder = "data/pilot_old_healthy";
class_three_folder = "data/pilot_old_unhealthy";

%% Text labels used on the plot (x-axis)
class_one_label = "Healthy young users";
class_two_label = "Healthy geriatric users";
class_three_label = "Cognitively impaired users";

%% Analysis parameters (match test/app_test_assr.m)
Fs = 256;
channel = 2;

paths1 = list_json_files_in_folder(class_one_folder);
paths2 = list_json_files_in_folder(class_two_folder);
paths3 = list_json_files_in_folder(class_three_folder);

[r40_1, r45_1] = local_collect(paths1, channel, Fs);
[r40_2, r45_2] = local_collect(paths2, channel, Fs);
[r40_3, r45_3] = local_collect(paths3, channel, Fs);

figure;
subplot(2, 1, 1);
plot_three_class_boxplot_with_dots( ...
    {r40_1, r40_2, r40_3}, ...
    [class_one_label, class_two_label, class_three_label], ...
    "ASSR 40 Hz: high / low trial peak power (linear PSD)", ...
    "40 Hz ratio");

subplot(2, 1, 2);
plot_three_class_boxplot_with_dots( ...
    {r45_1, r45_2, r45_3}, ...
    [class_one_label, class_two_label, class_three_label], ...
    "ASSR 45 Hz: high / low trial peak power (linear PSD)", ...
    "45 Hz ratio");

function [v40, v45] = local_collect(paths, channel, Fs)
    v40 = [];
    v45 = [];
    for i = 1:numel(paths)
        [a40, a45] = metric_assr_high_over_low_ratios(paths(i), channel, Fs);
        if isfinite(a40)
            v40(end + 1, 1) = a40; %#ok<AGROW>
        end
        if isfinite(a45)
            v45(end + 1, 1) = a45; %#ok<AGROW>
        end
    end
end
