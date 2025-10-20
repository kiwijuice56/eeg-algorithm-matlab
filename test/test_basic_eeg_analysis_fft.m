Fs = 256; 

figure; hold on;

trials = {'eyes_open_3', 'eyes_closed_3'};
for trialnum = 1:length(trials) 
    trial = trials{trialnum};

    % Read data
    signals = read_from_json_file_raw(sprintf("data/eric_alfaro/%s.json", trial), "eeg");
    
    % Create EEG struct
    EEG = eeg_emptyset;
    EEG.data = [signals.eeg.data(1:4,:)];
    EEG.nbchan = 4;
    EEG.pnts = size(signals.eeg.time, 1);
    EEG.trials = 1;
    EEG.srate = 256;
    EEG.times = signals.eeg.time;
    EEG = eeg_checkset(EEG);
    
    % Rereference
    EEG = pop_reref(EEG, []);
    
    channel = 1;
    signal = EEG.data(channel, :);
    
    % Detrend and remove DC
    signal = detrend(signal);
    signal = highpass(signal, 1, Fs);
    
    N = length(signal);          % Number of samples
    X = fft(signal);             % Compute FFT
    X = X(1:floor(N/2));         % Keep only positive frequencies
    f = (0:floor(N/2)-1)*(Fs/N); % Frequency vector
    
    % Plot magnitude
    plot(f, abs(X), 'DisplayName', replace(trial, "_", " ")); 
    
end

title('EEG FFT');
xlim([0 20]);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;
legend;
