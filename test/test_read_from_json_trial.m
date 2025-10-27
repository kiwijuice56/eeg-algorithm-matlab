trials = read_from_json_file_raw_trial("data/erp/f38cedd5-55e8-4e0e-be2c-9aae00ff69a6.json");

Fs = 256;
channel = 2;
highpassFrequency = 0.5;
lowpassFrequency = 50;

plottedTrials = {trials.related, trials.unrelated};
figure; hold on;

for j = 1:length(plottedTrials)
    trial = plottedTrials{j};
    averageEeg = lowpass(highpass(trial{1}.eeg(:,channel), highpassFrequency, Fs), lowpassFrequency, Fs);
    for i = 2:length(trial)
        a = averageEeg;
        b = lowpass(highpass(trial{i}.eeg(:,channel), highpassFrequency, Fs), lowpassFrequency, Fs);
        
        minLength = min(length(a), length(b));
        a = a(1:minLength);
        b = b(1:minLength);
        
        averageEeg = a + b;
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
