function signals = read_from_json_file(filename)
    % LOAD_AND_RESAMPLE_JSON Loads and resamples JSON time series data 
    % to 1000 Hz.
    %
    % Input:
    %   filename - string, path to .json file
    %
    % Output:
    %   signals - struct, each field is a channel (e.g., eeg0, eeg1, ...),
    %             containing .time (resampled timeline) and .value (resampled values)

    % Read JSON file
    rawText = fileread(filename);
    data = jsondecode(rawText);

    % Target sampling frequency
    fs = 1000;

    % Loop through each top-level signal type
    signalNames = fieldnames(data);
    for i = 1:numel(signalNames)
        name = signalNames{i};
        entry = data.(name);

        % Skip if missing or empty .value (artifact signals)
        if ~isfield(entry, "value") || isempty(entry.value)
            continue;
        end

        % Extract time (microseconds to seconds)
        t = double(entry.time(:)) / 1e6;
        t = t - t(1); % Normalize to start at 0

        % Extract values (n × m numeric matrix)
        values = double(entry.value);

        % Ensure timestamps are sorted
        [t, idx] = sort(t);
        values = values(idx, :);

        % Create uniform time base
        tStart = t(1);
        tEnd = t(end);
        tResamp = (tStart : 1/fs : tEnd)';

        % Resample each channel independently
        vResamp = interp1(t, values, tResamp, 'linear', 'extrap');

        % Store each channel separately
        for ch = 1:size(vResamp,2)
            chanName = sprintf('%s%d', lower(name), ch-1);  % eeg0, eeg1, ...
            signals.(chanName).time = tResamp;
            signals.(chanName).value = vResamp(:,ch);
        end
    end
end