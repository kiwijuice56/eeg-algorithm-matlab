data = read_from_json_file_raw_trial_joined("data/erp/4792c1b0-41d7-4363-ad00-69aa704e5b18.json");

channel = 3;
Fs = 256;
trialLength = 0.5 + 3.0;
trialSampleCount = round(trialLength * Fs);

[b,a] = butter(2, [2 30] / (Fs/2), 'bandpass');
eeg = filtfilt(b, a, detrend(data.eeg.values(:, channel)));

averagedEeg = {[], []};
averagedEegCount = {0, 0};

figure; hold on;

for j = 1:length(data.trial_labels)
    window = eeg(1 + trialSampleCount * (j - 1) : min(end, trialSampleCount * j));

    length(window)

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
        averagedEegCount{trialIndex} = averagedEegCount{trialIndex} + 1;
    end
end

for i = 1:2
    averagedEeg{i} = averagedEeg{i} / averagedEegCount{i};
    plot((1 : length(averagedEeg{i})) / Fs, averagedEeg{i}, 'LineWidth', 1.5);
end


set(gca, 'YDir','reverse')
xline(0.5,'-k',{'Stimulus start'}); 
xline(3.5,'-k',{'Stimulus end'});

%xline(1.1,'--r',{'N1'}); 
%xline(1.2,'--g',{'P2'}); 
%xline(1.4,'--r',{'N400'}); 
legend('Normal', 'Strange')
xlabel('Time (s)');
ylabel('Amplitude (microvolts)');
title('ERP of audio sentence task (right forehead)');
