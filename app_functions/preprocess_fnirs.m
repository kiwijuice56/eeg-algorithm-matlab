function [preprocessed_fnirs_matrix] = preprocess_fnirs(fnirs_matrix)
%GD_PREPROCESS_EEG 
arguments (Input)
    fnirs_matrix (8,:) double
end

arguments (Output)
    preprocessed_fnirs_matrix (:,16) double
end

preprocessed_fnirs_matrix = fnirs_matrix';

end