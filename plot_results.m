function plot_results(results_path)
% PLOT_RESULTS - Generates accurate plots for LEAPD results using actual metrics

if nargin < 1
    error('Please provide the path to your test_results.mat file.');
end

S = load(results_path);
if ~isfield(S, 'results')
    error('File must contain a variable named "results".');
end
results = S.results;

% Detect mode
if isfield(S, 'cfg') && isfield(S.cfg, 'mode')
    mode_type = string(S.cfg.mode);
    fprintf('Detected mode: %s\n', mode_type);
else
    if isfield(results.single(1).metrics, 'ACC')
        mode_type = "classification";
    elseif isfield(results.single(1).metrics, 'Rho')
        mode_type = "correlation";
    else
        mode_type = "unknown";
    end
end

% Create figure directory
save_dir = fileparts(results_path);
fig_dir = fullfile(save_dir, 'figures');
if ~exist(fig_dir, 'dir'), mkdir(fig_dir); end

fprintf('Generating plots for %s mode...\n', mode_type);

% --------------------------------------------------------------
% 1. ACCURATE Performance Summary Plot (FIXED)
% --------------------------------------------------------------
if strcmp(mode_type, "classification")
    figure('Position', [100, 100, 1200, 800]);
    
    % Single channel performances
    channels = string({results.single.channel});
    single_accs = arrayfun(@(x) x.metrics.ACC, results.single);
    
    % Combo performances
    combo_accs = [];
    combo_sizes = [];
    for k = 1:length(results.combos)
        if ~isempty(results.combos(k).best)
            combo_accs(end+1) = results.combos(k).best.metrics.ACC;
            combo_sizes(end+1) = k;
        end
    end
    
    subplot(2,2,1);
    bar(single_accs, 'FaceColor', [0.2 0.6 0.8]);
    set(gca, 'XTick', 1:length(channels), 'XTickLabel', channels, ...
        'XTickLabelRotation', 45);
    ylabel('Accuracy (%)');
    title('Single Channel Performance');
    ylim([0 100]);
    grid on;
    
    % Add value labels on bars
    for i = 1:length(single_accs)
        text(i, single_accs(i) + 2, sprintf('%.1f%%', single_accs(i)), ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
    
    subplot(2,2,2);
    plot(combo_sizes, combo_accs, 'o-', 'LineWidth', 2, 'MarkerSize', 8, ...
        'Color', [0.8 0.2 0.2], 'MarkerFaceColor', [0.8 0.2 0.2]);
    xlabel('Number of Channels Combined');
    ylabel('Accuracy (%)');
    title('Multi-Channel Combination Performance');
    ylim([0 100]);
    grid on;
    
    % Add value labels
    for i = 1:length(combo_accs)
        text(combo_sizes(i), combo_accs(i) + 2, sprintf('%.1f%%', combo_accs(i)), ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    end
    
    % Best combo details
    [best_acc, best_idx] = max(combo_accs);
    best_combo = results.combos(combo_sizes(best_idx)).best;
    
    subplot(2,2,3);
    metrics = best_combo.metrics;
    metric_names = {'ACC', 'SEN', 'SPC', 'PPV', 'NPV'};
    metric_values = [metrics.ACC, metrics.SEN*100, metrics.SPC*100, ...
                    metrics.PPV*100, metrics.NPV*100];
    
    bar(metric_values, 'FaceColor', [0.3 0.7 0.3]);
    set(gca, 'XTickLabel', metric_names);
    ylabel('Percentage (%)');
    title(sprintf('Best %d-Channel Combo Metrics', combo_sizes(best_idx)));
    ylim([0 100]);
    grid on;
    
    % Add value labels
    for i = 1:length(metric_values)
        text(i, metric_values(i) + 2, sprintf('%.1f', metric_values(i)), ...
            'HorizontalAlignment', 'center', 'FontSize', 10);
    end
    
    subplot(2,2,4);
    % Confusion matrix visualization
    cm = [best_combo.metrics.TP, best_combo.metrics.FP; 
          best_combo.metrics.FN, best_combo.metrics.TN];
    imagesc(cm);
    textStrings = num2str(cm(:), '%d');
    textStrings = strtrim(cellstr(textStrings));
    [x, y] = meshgrid(1:2);
    text(x(:), y(:), textStrings(:), 'HorizontalAlignment', 'center', ...
        'FontWeight', 'bold', 'FontSize', 14, 'Color', 'white');
    
    set(gca, 'XTick', 1:2, 'XTickLabel', {'Predicted 1', 'Predicted 0'});
    set(gca, 'YTick', 1:2, 'YTickLabel', {'Actual 1', 'Actual 0'});
    title('Confusion Matrix');
    colormap(parula);
    colorbar;
    
    sgtitle('LEAPD Classification Results Summary', 'FontSize', 16, 'FontWeight', 'bold');
    saveas(gcf, fullfile(fig_dir, 'Classification_Summary.png'));
    
    fprintf('Best performance: %d channels = %.1f%% accuracy\n', ...
        combo_sizes(best_idx), best_acc);
    fprintf('Best channels: %s\n', strjoin(best_combo.channels, ', '));
end

% --------------------------------------------------------------
% 2. Channel Ranking Plot (FIXED)
% --------------------------------------------------------------
if isfield(results, 'single')
    figure('Position', [100, 100, 800, 600]);
    
    channels = string({results.single.channel});
    if strcmp(mode_type, "classification")
        vals = arrayfun(@(x) x.metrics.ACC, results.single);
        metricLabel = 'Accuracy (%)';
        titleStr = 'Channel-wise Classification Accuracy';
    else
        vals = arrayfun(@(x) x.metrics.Rho, results.single);
        metricLabel = 'Spearman \\rho';
        titleStr = 'Channel-wise Correlation';
    end
    
    [sorted_vals, sort_idx] = sort(vals, 'descend');
    sorted_channels = channels(sort_idx);
    
    barh(sorted_vals, 'FaceColor', [0.4 0.4 0.8]);
    set(gca, 'YTick', 1:length(sorted_channels), 'YTickLabel', sorted_channels);
    xlabel(metricLabel);
    title(titleStr);
    grid on;
    
    % Add value labels
    for i = 1:length(sorted_vals)
        text(sorted_vals(i) + 0.01*max(sorted_vals), i, ...
            sprintf('%.3f', sorted_vals(i)), 'FontWeight', 'bold');
    end
    
    saveas(gcf, fullfile(fig_dir, 'Channel_Ranking.png'));
end

% --------------------------------------------------------------
% 3. Performance vs Channel Count (FIXED)
% --------------------------------------------------------------
if isfield(results, 'combos') && strcmp(mode_type, "classification")
    figure('Position', [100, 100, 600, 400]);
    
    combo_sizes = [];
    combo_accs = [];
    combo_channels = {};
    
    for k = 1:length(results.combos)
        if ~isempty(results.combos(k).best)
            combo_sizes(end+1) = k;
            combo_accs(end+1) = results.combos(k).best.metrics.ACC;
            combo_channels{end+1} = results.combos(k).best.channels;
        end
    end
    
    plot(combo_sizes, combo_accs, 's-', 'LineWidth', 2, 'MarkerSize', 8, ...
        'Color', [0.9 0.4 0.1], 'MarkerFaceColor', [0.9 0.4 0.1]);
    
    xlabel('Number of Channels Combined');
    ylabel('Accuracy (%)');
    title('Performance vs Channel Combination Size');
    ylim([0 100]);
    grid on;
    
    % Add channel labels
    for i = 1:length(combo_sizes)
        text(combo_sizes(i), combo_accs(i) - 3, ...
            strjoin(combo_channels{i}, '+'), ...
            'HorizontalAlignment', 'center', 'FontSize', 8, ...
            'Rotation', 45);
    end
    
    saveas(gcf, fullfile(fig_dir, 'Performance_vs_Channels.png'));
end

fprintf('\n All accurate plots saved in: %s\n', fig_dir);
fprintf('   - Classification_Summary.png\n');
fprintf('   - Channel_Ranking.png\n');
fprintf('   - Performance_vs_Channels.png\n');

end