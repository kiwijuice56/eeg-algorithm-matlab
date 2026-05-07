function v = app_json_scalar(field)
%APP_JSON_SCALAR Extract numeric scalar from read_from_json_file_app task/stimulus field.
    if isnumeric(field) && isscalar(field)
        v = double(field);
        return;
    end
    if isstruct(field)
        if isfield(field, "data")
            d = field.data;
            if isnumeric(d) && ~isempty(d)
                v = double(d(1));
                return;
            end
        end
        if isfield(field, "value")
            vv = field.value;
            if isnumeric(vv) && ~isempty(vv)
                v = double(vv(1));
                return;
            end
        end
    end
    v = NaN;
end
