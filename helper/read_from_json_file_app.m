function signals = read_from_json_file_app(filename, task, type)
    % READ_FROM_JSON_FILE Loads JSON time series data.
    %
    % Input:
    %   filename - string, path to .json file
    %   task     - string, the prefix of the task type (no_stimulus,
    %   assr_listening, oddball, reaction) 
    %   type     - string, the prefix of the stream type (optics, eeg, etc.)
    %
    % Output:
    %   signals - struct, each field is a stream (e.g., eeg, optics),
    %             containing .time (nx1) and .data (nxm)

    % Read JSON file
    text = fileread(filename);
    text = strrep(text, 'nan', 'null');
    data = jsondecode(text).(task);

    signalNames = fieldnames(data);
    for i = 1:numel(signalNames)
        name = signalNames{i};
        entry = data.(name);

        if ~startsWith(name, type)
            continue;
        end
        
        if ~isfield(entry, "value") || isempty(entry.value)
            signals.(name) = entry;
            continue;
        end

        % Extract and sort time/value
        values = double(entry.value);
        t = double(entry.time);
        [t, idx] = sort(t);
        values = values(idx, :);

        % Store each channel
        signals.(name).time = t;
        signals.(name).data = values';
    end
end
