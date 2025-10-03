% Read data
fS = 10;
signals = read_from_json_file("data/eric_alfaro/breath_holding_1.json", fS);

% Raw units are in microamps 

% 730nm
left_outer = signals.optics0.value;
right_outer = signals.optics1.value;

% 850nm
left_inner = signals.optics2.value;
right_inner = signals.optics3.value;

% Band-pass filter range (Hz)
fpass = [0.05 2]; 

% Optional: Plot the original and filtered signals for comparison
t = (0:length(left_outer)-1) / fS; % Time vector

filtered_left_outer = bandpass(left_outer, fpass, fS);
filtered_right_outer = bandpass(right_outer, fpass, fS);
filtered_left_inner = bandpass(left_inner, fpass, fS);
filtered_right_inner = bandpass(right_inner, fpass, fS);

figure;
subplot(2, 2, 1);
plot(t, left_outer);
hold on;
plot(t, filtered_left_outer);
title('Left Outer Signal');
legend('Original', 'Filtered');

subplot(2, 2, 2);
plot(t, right_outer);
hold on;
plot(t, filtered_right_outer);
title('Right Outer Signal');
legend('Original', 'Filtered');

subplot(2, 2, 3);
plot(t, left_inner);
hold on;
plot(t, filtered_left_inner);
title('Left Inner Signal');
legend('Original', 'Filtered');

subplot(2, 2, 4);
plot(t, right_inner);
hold on;
plot(t, filtered_right_inner);
title('Right Inner Signal');
legend('Original', 'Filtered');