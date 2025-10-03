% Read data
fS = 64; % base rampling rate of optics in the Muse headband
signals = read_from_json_file("data/eric_alfaro/breath_holding_1.json", fS);

input_marker = signals.keyboard_input0.value;

% Raw units are in microamps 

% 730nm
left_outer = signals.optics0.value;
right_outer = signals.optics1.value;

% 850nm
left_inner = signals.optics2.value;
right_inner = signals.optics3.value;

% Band-pass filter and trim our signals 
fpass = 1.5; % Hz
trim = 30; % number of samples

filtered_left_outer = lowpass(left_outer, fpass, fS);
filtered_left_outer = filtered_left_outer(trim:end - trim);

filtered_right_outer = lowpass(right_outer, fpass, fS);
filtered_right_outer = filtered_right_outer(trim:end - trim);

filtered_left_inner = lowpass(left_inner, fpass, fS);
filtered_left_inner = filtered_left_inner(trim:end - trim);

filtered_right_inner = lowpass(right_inner, fpass, fS);
filtered_right_inner = filtered_right_inner(trim:end - trim);

input_marker = input_marker(trim:end - trim);

% Calculate baseline intensity
baseline_samples = fS * 5; % first 5 seconds
I0_left = [mean(filtered_left_outer(1:baseline_samples)), ...
           mean(filtered_left_inner(1:baseline_samples))];

I0_right = [mean(filtered_right_outer(1:baseline_samples)), ...
            mean(filtered_right_inner(1:baseline_samples))];

OD_left = -log([filtered_left_outer ./ I0_left(1), ...
                filtered_left_inner ./ I0_left(2)]);

OD_right = -log([filtered_right_outer ./ I0_right(1), ...
                 filtered_right_inner ./ I0_right(2)]);

% Extinction coefficients
epsilon = [390,   1102.2;   % 730 nm
           1058,  691.32];  % 850 nm

d = 3.0;            % cm (measurea actual later)
DPF = [5.5, 5.0];   % refine based on user
scale = d .* DPF;

E = [epsilon(1,:)*scale(1)*1e-6;
     epsilon(2,:)*scale(2)*1e-6]; % scale to µM
pinvE = pinv(E);

DeltaC_left  = (pinvE * OD_left')';   % N x 2
DeltaC_right = (pinvE * OD_right')';

HbO_left = DeltaC_left(:,1);
HbR_left = DeltaC_left(:,2);

HbO_right = DeltaC_right(:,1);
HbR_right = DeltaC_right(:,2);

t = (0:length(HbO_left)-1)/fS;

figure;
subplot(3,1,1);
plot(t, HbO_left, 'r', t, HbR_left, 'b');
xlabel('Time (s)'); ylabel('\Delta [Hb] (\muM)');
title('Left channel'); legend('HbO','HbR');

subplot(3,1,2);
plot(t, HbO_right, 'r', t, HbR_right, 'b');
xlabel('Time (s)'); ylabel('\Delta [Hb] (\muM)');
title('Right channel'); legend('HbO','HbR');

% Trigger plot
subplot(3,1,3);
plot(t, input_marker, 'g');
xlabel('Time (s)');
ylabel('Trigger');
title('Input Trigger');