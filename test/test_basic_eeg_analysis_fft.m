% Read data
signals = read_from_json_file("data/eric_alfaro/eyes_open_3.json");
signal_open = signals.notch_filtered_eeg1.value;

signals = read_from_json_file("data/eric_alfaro/eyes_closed_3.json");
signal_closed = signals.notch_filtered_eeg1.value;

Fs = 256; 

% Detrend and remove DC
signal_open = detrend(signal_open);
signal_open = highpass(signal_open, 1, Fs);

signal_closed = detrend(signal_closed);
signal_closed = highpass(signal_closed, 1, Fs);

N = length(signal_closed);          % Number of samples
X = fft(signal_closed);             % Compute FFT
X = X(1:floor(N/2));         % Keep only positive frequencies
f = (0:floor(N/2)-1)*(Fs/N); % Frequency vector

% Plot magnitude
figure;
plot(f, abs(X)); hold on

N = length(signal_open);          
X = fft(signal_open);            
X = X(1:floor(N/2));        
f = (0:floor(N/2)-1)*(Fs/N);

plot(f, abs(X));

xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('EEG FFT (left forehead)');
xlim([0 20]);
grid on;
