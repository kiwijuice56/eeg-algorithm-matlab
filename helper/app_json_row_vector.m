function v = app_json_row_vector(field)
%APP_JSON_ROW_VECTOR Extract 1 x N double row vector from app JSON field.
    v = [];
    if isnumeric(field)
        v = double(field(:))';
        return;
    end
    if isstruct(field) && isfield(field, "data")
        d = double(field.data);
        if isempty(d)
            return;
        end
        [nr, nc] = size(d);
        if nr == 1
            v = d(1, :);
        elseif nc == 1
            v = d(:, 1)';
        elseif nr >= nc
            v = d(1, :);
        else
            v = d(:, 1)';
        end
        return;
    end
end
