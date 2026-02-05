data = read_from_json_file_raw_trial_joined("data/erp/2d158e7a-446e-4c3c-9fc2-f02edcc1484e.json");

channel = 2; % Left forehead
Fs = 256;
trialLength = 0.5 + 1.0; % 0.5 seconds before stimulus, 1.0 seconds after stimulus
trialSampleCount = round(trialLength * Fs);

% Filter the EEG data
N   = 12;   % Order
Fc1 = 1;  % First Cutoff Frequency
Fc2 = 100;   % Second Cutoff Frequency
h  = fdesign.bandpass('N,F3dB1,F3dB2', N, Fc1, Fc2, Fs);
Hd = design(h, 'butter');
[b, a] = tf(Hd);
eeg = filtfilt(b, a, data.notch_filtered_eeg.values(:, channel));

% Perform ERP by averaging windows for two trial types

averagedEeg = {[], []};
averagedEegCount = {0, 0};

figure; hold on;

% Skip some trials to avoid filtering issues
skip = 1;
for j = (skip + 1):length(data.trial_labels) - skip    
    stimulusTime = data.stimulus_times(j) - data.start_times(1);
    stimulusTimestamp = 1 + round(stimulusTime * Fs);
    startTimestamp = stimulusTimestamp - round(0.5 * Fs);

    window = eeg(startTimestamp : min(end, startTimestamp + trialSampleCount));
    baseline = mean(window(1:round(0.5 * Fs)));
    % window = window - baseline;
    
    label = data.trial_labels(j);
    if startsWith(label, "trial_related")
        trialIndex = 1;
    else
        trialIndex = 2;
    end

    if isempty(averagedEeg{trialIndex})
        averagedEeg{trialIndex} = window;
    else
        averagedEeg{trialIndex} = averagedEeg{trialIndex} + window;
    end

    averagedEegCount{trialIndex} = averagedEegCount{trialIndex} + 1;
end

for i = 1:2
    averagedEeg{i} = averagedEeg{i} / averagedEegCount{i};
    plot((1 : length(averagedEeg{i})) / Fs, averagedEeg{i}, 'LineWidth', 1);
end

set(gca, 'YDir','reverse')
xline(0.5,'-k',{'Stimulus start'}); 
xline(0.6,'-b',{'P1'}); 
xline(0.7,'-b',{'P2'}); 
xline(0.8,'-b',{'P3'}); 

legend('Normal', 'Strange')
xlabel('Time (s)');
ylabel('Amplitude (microvolts)');
title('ERP of oddball task (left forehead)');
