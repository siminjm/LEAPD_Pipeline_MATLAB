function leapd_demo()
% LEAPD_DEMO - Complete demonstration of the LEAPD pipeline
% Runs preprocessing, creates synthetic data, trains model, tests, and generates plots
%
% Usage:
%   leapd_demo()
%
% Outputs:
%   - Creates synthetic training and test datasets
%   - Trains LEAPD classification model
%   - Tests model on held-out data
%   - Generates comprehensive plots
%   - Saves all results to demo_results/ folder

fprintf('=============================================\n');
fprintf('         LEAPD PIPELINE DEMONSTRATION\n');
fprintf('=============================================\n\n');

%% Step 1: Create Demo Datasets
fprintf('STEP 1: Creating synthetic demo datasets...\n');
utils.create_datasets();

% Verify files were created
if ~exist('train_data.mat', 'file') || ~exist('test_data.mat', 'file')
    error('Dataset creation failed!');
end
fprintf('Demo datasets created successfully\n\n');

%% Step 2: Run Preprocessing Demo
fprintf('STEP 2: Running EEG preprocessing demo...\n');
try
    cd Preprocessing;
    Demo;
    cd ..;
    fprintf('Preprocessing demo completed successfully\n\n');
catch ME
    cd ..;
    fprintf('Preprocessing demo had issues: %s\n', ME.message);
    fprintf('   Continuing with main pipeline...\n\n');
end

%% Step 3: Train LEAPD Model
fprintf('STEP 3: Training LEAPD classification model...\n');
cfg_train = struct();
cfg_train.mode = 'classification';
cfg_train.data_train = 'train_data.mat';
cfg_train.labels_file = 'ClinicalLabels_train.xlsx';
cfg_train.save_dir = 'demo_train_results';
cfg_train.f1_grid = [0.5, 1.0, 1.5];
cfg_train.f2_grid = [20, 30, 40];
cfg_train.orders = [2, 3, 4];
cfg_train.is_preprocessed = false;

results_train = main_train(cfg_train);
fprintf('Training completed: %d channels with valid models\n\n', length(results_train.BestParamsAll));

%% Step 4: Test LEAPD Model
fprintf('STEP 4: Testing LEAPD model on held-out data...\n');
cfg_test = struct();
cfg_test.mode = 'classification';
cfg_test.data_test = 'test_data.mat';
cfg_test.trained_model = 'demo_train_results/BestParamsAll.mat';
cfg_test.labels_file = 'ClinicalLabels_test.xlsx';
cfg_test.save_dir = 'demo_test_results';
cfg_test.combo_sizes = 1:4;

results_test = main_test(cfg_test);
fprintf('Testing completed successfully\n\n');

%% Step 5: Generate Results Plots
fprintf('STEP 5: Generating comprehensive results plots...\n');
plot_results('demo_test_results/test_results.mat');
fprintf('All plots generated and saved\n\n');

%% Step 6: Display Summary Results
fprintf('STEP 6: Demo Results Summary\n');
fprintf('----------------------------------------\n');

% Load test results for summary
S = load('demo_test_results/test_results.mat');
results = S.results;

% Single channel performances
channels = {results.single.channel};
single_accs = arrayfun(@(x) x.metrics.ACC, results.single);
[best_single_acc, best_single_idx] = max(single_accs);

fprintf('Single Channel Results:\n');
for i = 1:length(channels)
    fprintf('   %s: %.1f%% accuracy', channels{i}, single_accs(i));
    if i == best_single_idx
        fprintf(' BEST SINGLE\n');
    else
        fprintf('\n');
    end
end

% Multi-channel combinations
fprintf('\nMulti-Channel Combinations:\n');
for k = 1:length(results.combos)
    if ~isempty(results.combos(k).best)
        combo = results.combos(k).best;
        fprintf('   %d channels (%s): %.1f%% accuracy', ...
            k, strjoin(combo.channels, '+'), combo.metrics.ACC);
        
        % Find if this is the best overall
        all_accs = arrayfun(@(x) x.best.metrics.ACC, results.combos(~arrayfun(@(x) isempty(x.best), results.combos)));
        if combo.metrics.ACC == max(all_accs)
            fprintf(' OVERALL BEST\n');
        else
            fprintf('\n');
        end
    end
end

fprintf('\n----------------------------------------\n');
fprintf('LEAPD DEMO COMPLETED SUCCESSFULLY!\n');
fprintf('----------------------------------------\n');
fprintf('Generated files:\n');
fprintf('   - train_data.mat, test_data.mat (synthetic data)\n');
fprintf('   - ClinicalLabels_train.xlsx, ClinicalLabels_test.xlsx\n');
fprintf('   - demo_train_results/ (trained models)\n');
fprintf('   - demo_test_results/ (test results)\n');
fprintf('   - demo_test_results/figures/ (all plots)\n');
fprintf('\nYour LEAPD pipeline is ready for real EEG data!\n');

end