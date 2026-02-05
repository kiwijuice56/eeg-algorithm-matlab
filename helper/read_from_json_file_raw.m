function signals = read_from_json_file_raw(filename, type)
    % READ_FROM_JSON_FILE Loads JSON time series data.
    %
    % Input:
    %   filename - string, path to .json file
    %   type     - string, the prefix of the stream type (optics, eeg, etc.)
    %
    % Output:
    %   signals - struct, each field is a channel (e.g., eeg0, eeg1, ...),
    %             containing .time (nx1) and .data (nx1)

    % Read JSON file
    text = fileread(filename);
    text = strrep(text, 'nan', 'null');
    data = jsondecode(text);

    signalNames = fieldnames(data);
    for i = 1:numel(signalNames)
        name = signalNames{i};
        entry = data.(name);

        % Skip if missing, empty .value, or not EEG
        if ~isfield(entry, "value") || isempty(entry.value) || ~startsWith(name, type)
            continue;
        end

        % Extract and sort time/value
        values = double(entry.value);
        t = double(entry.time);
        % [t, idx] = sort(t);
        % values = values(idx, :);

        % Store each channel
        signals.(name).time = t;
        signals.(name).data = values';
    end
end
