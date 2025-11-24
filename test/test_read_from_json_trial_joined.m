data = read_from_json_file_raw_trial_joined("data/erp/f34273d4-a8df-4087-9ad2-1e544b652a2c.json");

channel = 2; % Left forehead
Fs = 256;
trialLength = 0.5 + 1.0;
trialSampleCount = round(trialLength * Fs);

[b_bp, a_bp] = butter(3, [0.5 30] / (Fs/2), 'bandpass');
eeg = filtfilt(b_bp, a_bp, data.notch_filtered_eeg.values(:, channel));

averagedEeg = {[], []};
averagedEegCount = {0, 0};

figure; hold on;


% Skip some trials to avoid filtering issues
skip = 3;
for j = (skip + 1):length(data.trial_labels) - skip
    startTime = data.start_times(j) - data.start_times(1);
    startTimestamp = 1 + round(startTime * Fs);

    window = eeg(startTimestamp : min(end, startTimestamp + trialSampleCount));
    baseline = mean(window(1:round(0.2 * Fs))); % first 400 ms pre-stimulus
    window = window - baseline;
    
    label = data.trial_labels(j);
    if startsWith(label, "trial_related")
        trialIndex = 1;
    else
        trialIndex = 2;
    end

    if isempty(averagedEeg{trialIndex})
        averagedEeg{trialIndex} = window;
    else
        minLength = min(length(averagedEeg{trialIndex}), length(window));

        trimmedAverageEeg = averagedEeg{trialIndex}(1:minLength);
        trimmedWindow = window(1:minLength);
     
        averagedEeg{trialIndex} = trimmedAverageEeg + trimmedWindow;
    end

    averagedEegCount{trialIndex} = averagedEegCount{trialIndex} + 1;
end

for i = 1:2
    averagedEeg{i} = averagedEeg{i} / averagedEegCount{i};
    plot((1 : length(averagedEeg{i})) / Fs, averagedEeg{i}, 'LineWidth', 1);
end


set(gca, 'YDir','reverse')
xline(0.5,'-k',{'Stimulus start (approx.)'}); 

legend('Normal', 'Strange')
xlabel('Time (s)');
ylabel('Amplitude (microvolts)');
title('ERP of audio sentence task (right forehead)');
