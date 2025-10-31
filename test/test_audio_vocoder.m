% Code generated with LLM, then modifier and reviewed based on 
% this paper: 10.1016/j.heares.2020.108155
% The goal is to have a value that we can vary from 0 to 1 to modify
% how understandable a sentence of speech is. We can do this more
% intelligently than using raw noise by preserving some frequency data
% necessary for interpreting speech

% Note: this code uses butter filters instead of elliptic 

[signal, fs] = audioread('data/audio/OSR_us_000_0010_8k.wav');
signal = mean(signal, 2);   % convert to mono if stereo

% Normalize volume
rmsTarget = 0.1; 
rmsCurrent = rms(signal);
signal = signal * (rmsTarget / rmsCurrent);

% Parameters (based on paper)
nBands = 8;
fRange = [180 8000]; % Hz
envLowpass = 160;    % Hz (for envelope smoothing)

% 0.0 = 0% understandable, 0.149 = 25%, 0.212 = 50%, 0.292 = 75%, 1.0 = 100%
expFactor = 0.292;   

% Make logarithmically spaced frequency bands (approx Greenwood spacing)
edges = logspace(log10(fRange(1)), log10(fRange(2)), nBands+1);

vocoded = zeros(size(signal));
for b = 1:nBands
    f1 = edges(b);
    f2 = edges(b+1);
    
    % Band-pass filter speech 
    bpFilt = designfilt('bandpassiir', 'FilterOrder', 6, ...
        'HalfPowerFrequency1', f1, 'HalfPowerFrequency2', f2, ...
        'SampleRate', fs, 'DesignMethod', 'butter');
    bandSig = filtfilt(bpFilt, signal);
    
    % Half-wave rectification
    env = abs(bandSig);
    
    % Low-pass filter envelope
    lpFilt = designfilt('lowpassiir', 'FilterOrder', 1, ...
        'HalfPowerFrequency', envLowpass, 'SampleRate', fs, ...
        'DesignMethod', 'butter');
    env = filtfilt(lpFilt, env);
    
    % Envelope manipulation (lower exponents mean a flatter envelope)
    env = env .^ expFactor;
    
    % Create white noise carrier for this band and apply envelope
    noise = randn(size(signal));
    noiseBand = filtfilt(bpFilt, noise);
    modSig = env .* noiseBand;
    
    % Sum to final audio output
    vocoded = vocoded + modSig;
end

vocoded = vocoded / max(abs(vocoded));
vocoded = real(vocoded);
% sound(vocoded, fs)
audiowrite('output.wav', vocoded, fs);