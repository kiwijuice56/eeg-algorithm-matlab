function [output] = read_from_json_file_raw_trial_joined(filename)
    % READ_FROM_JSON_FILE_TRIAL Loads JSON time series data (multiple trials).
    %
    % Input:
    %   filename - string, path to .json file
    %
    % Output:
    %   trials - struct, each field is a trial (e.g. trial_000, ...), another
    %            struct containing signal channels (e.g., eeg0, eeg1, ...),
    %            containing .data (nx1)

    % Read JSON file
    text = fileread(filename);
    text = strrep(text, 'nan', 'null');
    data = jsondecode(text);
    fieldNames = fieldnames(data);

    output = struct();
    output.trial_labels = data.trial_label;
    output.stimulus_times = data.stimulus_times;
    output.start_times = data.start_times;

    % Process data
    for i = 1:numel(fieldNames)
        name = fieldNames{i};
        entry = data.(name);

        % Skip metadata
        if strcmp(name, "metadata") || strcmp(name, "trial_count") || strcmp(name, "trial_label") || strcmp(name, "stimulus_times") || strcmp(name, "start_times") 
            continue;
        end

        output.(name).values = double(entry.value);
    end
end
