function paths = list_json_files_in_folder(folder)
%LIST_JSON_FILES_IN_FOLDER Return full paths to all *.json files in folder (non-recursive).
    folder = char(folder);
    if ~isfolder(folder)
        paths = strings(0, 1);
        return;
    end
    d = dir(fullfile(folder, '*.json'));
    [~, idx] = sort({d.name});
    d = d(idx);
    paths = strings(numel(d), 1);
    for i = 1:numel(d)
        paths(i) = string(fullfile(d(i).folder, d(i).name));
    end
end
