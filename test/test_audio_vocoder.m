% Code generated with LLM using this paper: 10.1016/j.heares.2020.108155
% The goal is to have a value that we can vary from 0 to 1 to modify
% how understandable a sentence of speech is. We can do this more
% intelligently than using raw noise by preserving some frequency data
% necessary for interpreting speech. The details are beyond my current
% understanding of audio processing, however

[signal, fs] = audioread('data/audio/harvard.wav');
signal = mean(signal, 2);   % convert to mono if stereo

% --- Define vocoder parameters ---
nBands = 8;
fRange = [180 8000];      % Hz
envLowpass = 160;         % Hz for envelope smoothing
expFactor = 1.0;          % 0.000 = noise, 0.212 = NVLow, 1.000 = NVHigh

% --- Make logarithmically spaced frequency bands (approx Greenwood spacing) ---
edges = logspace(log10(fRange(1)), log10(fRange(2)), nBands+1);

% --- Initialize output ---
vocoded = zeros(size(signal));

for b = 1:nBands
    % Band edges
    f1 = edges(b);
    f2 = edges(b+1);
    
    % --- Band-pass filter speech ---
    bpFilt = designfilt('bandpassiir', 'FilterOrder', 6, ...
        'HalfPowerFrequency1', f1, 'HalfPowerFrequency2', f2, ...
        'SampleRate', fs, 'DesignMethod', 'butter');
    bandSig = filtfilt(bpFilt, signal);
    
    % --- Envelope extraction ---
    env = abs(bandSig);  % rectification (simple absolute value)
    
    % Low-pass filter envelope at 160 Hz
    lpFilt = designfilt('lowpassiir', 'FilterOrder', 1, ...
        'HalfPowerFrequency', envLowpass, 'SampleRate', fs, ...
        'DesignMethod', 'butter');
    env = filtfilt(lpFilt, env);
    
    % --- Envelope manipulation ---
    env = env .^ expFactor;
    
    % --- White noise carrier for this band ---
    noise = randn(size(signal));
    noiseBand = filtfilt(bpFilt, noise);
    
    % --- Apply envelope to noise carrier ---
    modSig = env .* noiseBand;
    
    % --- Sum across channels ---
    vocoded = vocoded + modSig;
end

% Normalize overall level 
vocoded = vocoded / max(abs(vocoded)) * 0.99;

% Output
vocoded = real(vocoded);
sound(vocoded, fs)
