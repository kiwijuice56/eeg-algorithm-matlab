trials = read_from_json_file_raw_trial("data/erp/f38cedd5-55e8-4e0e-be2c-9aae00ff69a6.json");

Fs = 256;
channel = 3;
[b,a] = butter(4, [2 30] / (Fs/2), 'bandpass');

plottedTrials = {trials.related, trials.unrelated};
figure; hold on;


for j = 1:length(plottedTrials)
    trial = plottedTrials{j};
    
    averageEeg = filtfilt(b, a, detrend(trial{1}.eeg(:,channel)));
    for i = 2:length(trial)
        trialEeg = filtfilt(b, a, detrend(trial{i}.eeg(:,channel)));
        
        minLength = min(length(averageEeg), length(trialEeg));
        trimmedAverageEeg = averageEeg(1:minLength);
        trialEeg = trialEeg(1:minLength);
        
        averageEeg = trimmedAverageEeg + trialEeg;
    end
    
    eeg = averageEeg / length(trial);
    plot((1 : length(eeg)) / Fs, eeg);
end

set(gca, 'YDir','reverse')
xline(1.0,'-w',{'Stimulus'}); % Hardcoded, stimulus was presented at t = 1.0
xline(1.1,'--r',{'N1'}); 
xline(1.2,'--g',{'P2'}); 
xline(1.4,'--r',{'N400'}); 
legend('Related', 'Unrelated')
xlabel('Time (s)');
ylabel('Amplitude (microvolts)');
title('ERP of word pair task (right ear)');
