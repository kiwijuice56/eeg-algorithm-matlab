trials = read_from_json_file_raw_trial("data/erp/6f6643a9-0c90-4872-b243-67d125666784.json");

% Prepare figure
figure; hold on;

% Plot signals
Fs = 256;
channel = 2;

averageEeg = trials.related{1}.eeg(:,channel);
for i = 2:length(trials.related)
    % Sum the EEG data to the average, taking the length of the smaller array
    a = averageEeg;
    b = trials.related{i}.eeg(:,channel);
    
    minLength = min(length(a), length(b));
    a = a(1:minLength);
    b = b(1:minLength);
    
    averageEeg = a + b;
end
eeg = averageEeg / length(trials.related);

plot(eeg);

% Finalize plot
xlabel('Time (s)');
ylabel('Amplitude');
title('Basic EEG Plotting: From app');
grid on;
