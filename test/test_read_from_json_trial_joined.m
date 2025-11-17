data = read_from_json_file_raw_trial_joined("data/erp/837c65a8-4c95-421a-a70e-3d73e9ee62c5.json");

channel = 3; % Left forehead
Fs = 256;
trialLength = 0.5 + 2.8 + 0.6;
trialSampleCount = round(trialLength * Fs);

[b_bp, a_bp] = butter(3, [0.5 5] / (Fs/2), 'bandpass');
eeg = filtfilt(b_bp, a_bp, data.notch_filtered_eeg.values(:, channel));

averagedEeg = {[], []};
averagedEegCount = {0, 0};

figure; hold on;

% Skip some trials to avoid filtering issues
skip = 3;
for j = (skip + 1):length(data.trial_labels) - skip
    window = eeg(1 + trialSampleCount * (j - 1) : min(end, trialSampleCount * j));
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
xline(0.5,'-k',{'Stimulus start'}); 
xline(2.0,'-k',{'Approximate determining word point'});
xline(3.5,'-k',{'Stimulus end'});

legend('Normal', 'Strange')
xlabel('Time (s)');
ylabel('Amplitude (microvolts)');
title('ERP of audio sentence task (right forehead)');
