% Testing: Finding alpha peak from eyes closed data (or ASSR listening)
figure; hold on;

Fs = 256; 
channel = 1;
trial = "data\app_sample\fletcher_1.json";

signals = read_from_json_file_app(trial, "no_stimulus", "notch_filtered_eeg");
signal = signals.notch_filtered_eeg.data(channel, :);
% signal = signal(1: length(signal) / 2); % hacky way to split up the ASSR

% FFT and PSD params
win = hanning(2048); 
noverlap = 1024;      
nfft = 4096;          

% PSD
[pxx, f] = pwelch(signal, win, noverlap, nfft, Fs);
plot(f, pow2db(pxx)); 

% FFT
N = length(signal);          % Number of samples
X = fft(signal);             % Compute FFT
X = X(1:floor(N/2));         % Keep only positive frequencies
f = (0:floor(N/2)-1)*(Fs/N); % Frequency vector

% commented out to only show PSD
plot(f, abs(X));

title('Frequency domain plot (PSD, left ear, 60 seconds)');
xlim([1 30]);
%ylim([-20 20]);

xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
grid on;
legend;







N = length(signal);
X = fft(signal);
X = X(1:floor(N/2));
f_fft = (0:floor(N/2)-1) * (Fs/N);

power = abs(X).^2 / N;

% Smooth with a narrow moving average — just enough to suppress noise
% without smearing the peak
smooth_bins = 5;  % experiment with 3–10
power_smooth = movmean(power, smooth_bins);

% Find alpha peak in smoothed version
alpha_mask = f_fft >= 7 & f_fft <= 13;
[~, idx] = max(power_smooth(alpha_mask));
f_alpha = f_fft(alpha_mask);
peak_freq = f_alpha(idx);
fprintf('Alpha peak: %.2f Hz\n', peak_freq);

figure; hold on;
plot(f_fft, pow2db(power), 'Color', [0.7 0.7 0.7], 'DisplayName', 'Raw FFT');
plot(f_fft, pow2db(power_smooth), 'b', 'LineWidth', 1.5, 'DisplayName', 'Smoothed');
xline(peak_freq, '--r', sprintf('%.2f Hz', peak_freq));
xlim([0 30]); grid on; legend;
title('FFT with light smoothing for peak detection');