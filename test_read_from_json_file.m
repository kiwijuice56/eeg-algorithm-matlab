% Read data
signals = read_from_json_file("data/eric_alfaro/eyes_open_1.json");

% Prepare figure
figure; hold on;
plotOffset = 0;
legendEntries = {};

% Loop over all channels
chanNames = fieldnames(signals);
for k = 1:numel(chanNames)
    chan = signals.(chanNames{k});

    if ~startsWith(chanNames{k}, "eeg")
        continue
    end

    t = chan.time;
    y = chan.value;

    % Plot with offset so signals don't overlap
    plot(t, y + plotOffset, 'LineWidth', 1);
    legendEntries{end+1} = chanNames{k};

    % Increase offset for next signal (avoid zero-height channels)
    mag = max(abs(y));
    if mag == 0
        mag = 1;
    end
    plotOffset = plotOffset + mag * 1.5;
end

% Finalize plot
xlabel('Time (s)');
ylabel('Amplitude (offset)');
title('Resampled Signals');
legend(legendEntries, 'Location', 'eastoutside', 'Interpreter', 'none');
grid on;
hold off;