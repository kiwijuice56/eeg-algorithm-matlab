% Read data
loaded_file = load("-mat", "data\u6y9g_dataset\EEG Data\Raw EEG\set\mu01erp srjt.set");

n = 1000;
timestamps = loaded_file.times(1:n);
data = loaded_file.data(1,1:n);

plot(timestamps, data);