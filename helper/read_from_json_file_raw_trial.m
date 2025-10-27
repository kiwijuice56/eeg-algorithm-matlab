function [trials] = read_from_json_file_raw_trial(filename)
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

    trials = struct();
    trials.related = {};
    trials.unrelated = {};

    trialNames = fieldnames(data);
    for i = 1:numel(trialNames)
        name = trialNames{i};
        entry = data.(name);

        % Skip metadata
        if strcmp(name, "metadata") || strcmp(name, "trial_count")
            continue;
        end

        trialData = struct();
        signalNames = fieldnames(entry);
        for j = 1:numel(signalNames)
            signalName = signalNames{j};
            signalEntry = entry.(signalName);
            values = double(signalEntry.value);

            trialData.(signalName) = values;
        end

        if startsWith(name, "trial_related")
            trials.related{end + 1} = trialData;
        else
            trials.unrelated{end + 1} = trialData;
        end
    end
end
