% Testing: Visualizing built-in scores


% Read data
signals = read_from_json_file_raw("data/eric_alfaro/eyes_open_then_closed_4.json", "alpha_absolute");

% Prepare figure
figure; hold on;
legendEntries = {};

% Plot signals
plot(signals.alpha_absolute.time, signals.alpha_absolute.data(2, :));
legendEntries{end+1} = "Alpha Absolute (left forehead)";

plot(signals.alpha_absolute.time, signals.alpha_absolute.data(1, :));
legendEntries{end+1} = "Alpha Absolute (left ear)";

% Finalize plot
xlabel('Time (s)');
ylabel('Amplitude');
title('Alpha Absolute Score With Eyes Opening/Closing Test');
legend(legendEntries, 'Location', 'eastoutside', 'Interpreter', 'none');
grid on;
hold off;