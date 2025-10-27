function signals = read_from_json_file(filename, resampling_rate)
    % READ_FROM_JSON_FILE (DO NOT USE)
    % 
    % Loads and resamples JSON time series data 
    % to resampling_rate, aligning all signals on a common timeline with mean padding.
    % Time is normalized so that all signals start at 0 seconds.

    % Read JSON file
    text = fileread(filename);
    text = strrep(text, 'nan', 'null');
    data = jsondecode(text);

    % Target sampling frequency
    fs = resampling_rate;

    % --- First pass: gather all timestamps ---
    allStartTimes = [];
    allEndTimes   = [];

    signalNames = fieldnames(data);
    for i = 1:numel(signalNames)
        name = signalNames{i};
        entry = data.(name);

        % Skip if missing or empty .value
        if ~isfield(entry, "value") || isempty(entry.value)
            continue;
        end

        t = double(entry.time(:)) / 1e6;
        t = sort(t);

        allStartTimes(end+1) = t(1);
        allEndTimes(end+1)   = t(end);
    end

    % Define global time base (absolute)
    tStartGlobal = min(allStartTimes);
    tEndGlobal   = max(allEndTimes);
    tResampAbs   = (tStartGlobal : 1/fs : tEndGlobal)';

    % Normalize so time starts at 0
    tResamp = tResampAbs - tStartGlobal;

    % --- Second pass: resample onto global time base ---
    for i = 1:numel(signalNames)
        name = signalNames{i};
        entry = data.(name);

        if ~isfield(entry, "value") || isempty(entry.value)
            continue;
        end

        % Extract and sort time/value
        t = double(entry.time(:)) / 1e6;
        values = double(entry.value);
        [t, idx] = sort(t);
        values = values(idx, :);

        % Remove duplicate timestamps
        [tUnique, ~, ic] = unique(t, 'stable');
        if numel(tUnique) < numel(t)
            % Average values across duplicates
            valuesUnique = zeros(numel(tUnique), size(values,2));
            for k = 1:numel(tUnique)
                valuesUnique(k,:) = mean(values(ic==k,:), 1, 'omitnan');
            end
            t = tUnique;
            values = valuesUnique;
        end

        % Compute mean of each channel
        chanMeans = mean(values, 1, 'omitnan');

        % Resample with NaN padding first (absolute times)
        vResamp = interp1(t, values, tResampAbs, 'linear', NaN);

        % Replace NaNs (before start and after end) with mean
        for ch = 1:size(vResamp,2)
            nanIdx = isnan(vResamp(:,ch));
            vResamp(nanIdx,ch) = chanMeans(ch);
        end

        % Store each channel (normalized time)
        for ch = 1:size(vResamp,2)
            chanName = sprintf('%s%d', lower(name), ch-1);
            signals.(chanName).time  = tResamp;
            signals.(chanName).value = vResamp(:,ch);
        end
    end
end
