function labels = app_json_stimulus_labels(field)
%APP_JSON_STIMULUS_LABELS Return string array of stimulus labels, one per trial.
    labels = strings(0, 1);
    if isstruct(field) && isfield(field, "data")
        d = field.data;
        if iscell(d)
            for i = 1:numel(d)
                labels(end + 1, 1) = string(d{i}); %#ok<AGROW>
            end
            return;
        end
        if isstring(d)
            labels = d(:);
            return;
        end
        if ischar(d)
            labels = string(cellstr(d));
            return;
        end
    elseif iscell(field)
        for i = 1:numel(field)
            labels(end + 1, 1) = string(field{i}); %#ok<AGROW>
        end
    elseif isstring(field)
        labels = field(:);
    end
end
