% Batch fNIRS metric: mean HbO (first 10 s, outer L+R average) in reaction / same in resting
% Processing matches features/fnirs_oxygenation.m (MBLL, band-pass on deltaOD).

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

paths1 = list_json_files_in_folder(class_one_folder);
paths2 = list_json_files_in_folder(class_two_folder);
paths3 = list_json_files_in_folder(class_three_folder);

v1 = local_collect(paths1);
v2 = local_collect(paths2);
v3 = local_collect(paths3);

figure;
plot_three_class_boxplot_with_dots( ...
    {v1, v2, v3}, ...
    [class_one_label, class_two_label, class_three_label], ...
    "fNIRS: mean HbO first 10 s (reaction) / mean HbO first 10 s (rest)", ...
    "HbO ratio (reaction / rest)");

function v = local_collect(paths)
    v = [];
    for i = 1:numel(paths)
        r = metric_fnirs_reaction_rest_hbo_ratio(paths(i));
        if isfinite(r)
            v(end + 1, 1) = r; %#ok<AGROW>
        end
    end
end
