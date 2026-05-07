function plot_three_class_boxplot_with_dots(values_cell, class_labels, plot_title_str, ylab)
%PLOT_THREE_CLASS_BOXPLOT_WITH_DOTS One axes, three class positions; jittered dots behind boxes.
%   values_cell: 1x3 cell of numeric column vectors (may be empty).
%   class_labels: 1x3 string array or cellstr for x tick labels.

    assert(numel(values_cell) == 3 && numel(class_labels) == 3);

    cla;
    hold on;

    for c = 1:3
        v = values_cell{c}(:);
        v = v(isfinite(v));
        if isempty(v)
            continue;
        end
        xj = c + 0.07 * (rand(numel(v), 1) - 0.5);
        scatter(xj, v, 26, "filled", ...
            "MarkerFaceAlpha", 0.55, ...
            "MarkerEdgeColor", [0.15 0.15 0.15], ...
            "MarkerFaceColor", [0.35 0.55 0.85]);
    end

    y = [];
    g = [];
    for c = 1:3
        v = values_cell{c}(:);
        v = v(isfinite(v));
        if isempty(v)
            continue;
        end
        y = [y; v]; %#ok<AGROW>
        g = [g; c * ones(numel(v), 1)]; %#ok<AGROW>
    end

    if isempty(y)
        title(plot_title_str, "Interpreter", "none");
        xlim([0.5, 3.5]);
        set(gca, "XTick", 1:3, "XTickLabel", cellstr(class_labels));
        ylabel(ylab);
        grid on;
        text(0.5, 0.5, "No data", "HorizontalAlignment", "center", "Units", "normalized");
        return;
    end

    boxplot(y, g, "Symbol", "");
    set(gca, "XTick", 1:3, "XTickLabel", cellstr(class_labels));
    ylabel(ylab);
    title(plot_title_str, "Interpreter", "none");
    xlim([0.5, 3.5]);
    grid on;
    hold off;
end
