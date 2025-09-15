% Read data
signals_eyes_open = read_from_json_file("data/eric_alfaro/eyes_open_1.json");
signals_eyes_closed = read_from_json_file("data/eric_alfaro/eyes_closed_1.json");

% Prepare figure
figure; hold on;
legendEntries = {};

% Plot signals
plot(signals_eyes_open.alpha_absolute2.time, signals_eyes_open.alpha_absolute2.value, 'LineWidth', 1);
legendEntries{end+1} = "alpha absolute (eyes open, right forehead)";

plot(signals_eyes_closed.alpha_absolute2.time, signals_eyes_closed.alpha_absolute2.value, 'LineWidth', 1);
legendEntries{end+1} = "alpha absolute (eyes closed, right forehead)";

% Finalize plot
xlabel('Time (s)');
ylabel('Amplitude');
title('Alpha absolute (eyes open vs. closed)');
legend(legendEntries, 'Location', 'eastoutside', 'Interpreter', 'none');
grid on;
hold off;