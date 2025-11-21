% +utils/create_datasets.m
function create_datasets()
% CREATE_DATASETS - Creates both training and test EEG datasets with labels

fprintf('Creating training and test datasets...\n');

%% Create Training Data
fprintf('Creating training data...\n');
Fs = 500;
Nsubjects_train = 12;
Nchannels = 6;

% === CREATE THE VARIABLES - USE EXACT NAMES FROM THE START ===
EEG = cell(1, Nchannels);                    
Channel_location = cell(1, Nchannels);       

for ch = 1:Nchannels
    group1 = cell(1, Nsubjects_train);
    group2 = cell(1, Nsubjects_train);
    
    for subj = 1:Nsubjects_train
        t = (0:1999)' / Fs;
        signal1 = 1.2*sin(2*pi*10*t) + 0.5*sin(2*pi*6*t) + 0.4*randn(size(t));
        signal2 = 1.0*sin(2*pi*12*t) + 0.3*sin(2*pi*8*t) + 0.4*randn(size(t));
        
        group1{subj} = signal1;
        group2{subj} = signal2;
    end
    
    EEG{ch} = {group1, group2};
    Channel_location{ch} = sprintf('Ch%d', ch);
end

Filenames.group1 = arrayfun(@(x) sprintf('Train_S%d_g1', x), 1:Nsubjects_train, 'UniformOutput', false);
Filenames.group2 = arrayfun(@(x) sprintf('Train_S%d_g2', x), 1:Nsubjects_train, 'UniformOutput', false);

% Save training data - variables are already named correctly
save('train_data.mat', 'EEG', 'Channel_location', 'Filenames');
fprintf('Created train_data.mat with %d channels, %d training subjects\n', Nchannels, Nsubjects_train);

%% Create Test Data  
fprintf('Creating test data...\n');
Nsubjects_test = 8;

% === CREATE NEW VARIABLES WITH CORRECT NAMES ===
EEG = cell(1, Nchannels);                    
Channel_location = cell(1, Nchannels);       

for ch = 1:Nchannels
    group1 = cell(1, Nsubjects_test);
    group2 = cell(1, Nsubjects_test);
    
    for subj = 1:Nsubjects_test
        t = (0:1999)' / Fs;
        signal1 = 1.1*sin(2*pi*10*t) + 0.6*sin(2*pi*5.5*t) + 0.5*randn(size(t));
        signal2 = 0.9*sin(2*pi*12.5*t) + 0.4*sin(2*pi*7.5*t) + 0.5*randn(size(t));
        
        group1{subj} = signal1;
        group2{subj} = signal2;
    end
    
    EEG{ch} = {group1, group2};
    Channel_location{ch} = sprintf('Ch%d', ch);
end

Filenames.group1 = arrayfun(@(x) sprintf('Test_S%d_g1', x), 1:Nsubjects_test, 'UniformOutput', false);
Filenames.group2 = arrayfun(@(x) sprintf('Test_S%d_g2', x), 1:Nsubjects_test, 'UniformOutput', false);

% Save test data - variables are already named correctly
save('test_data.mat', 'EEG', 'Channel_location', 'Filenames');
fprintf('Created test_data.mat with %d channels, %d test subjects\n', Nchannels, Nsubjects_test);

%% Create Training Labels
fprintf('Creating training labels...\n');
train_IDs = [arrayfun(@(x) sprintf('Train_S%d_g1', x), 1:Nsubjects_train, 'UniformOutput', false), ...
             arrayfun(@(x) sprintf('Train_S%d_g2', x), 1:Nsubjects_train, 'UniformOutput', false)]';
train_Target = [ones(Nsubjects_train, 1); zeros(Nsubjects_train, 1)];

T_train = table(train_IDs, train_Target, 'VariableNames', {'ID', 'Target'});
writetable(T_train, 'ClinicalLabels_train.xlsx');
fprintf('Created ClinicalLabels_train.xlsx with %d training labels\n', numel(train_IDs));

%% Create Test Labels
fprintf('Creating test labels...\n');
test_IDs = [arrayfun(@(x) sprintf('Test_S%d_g1', x), 1:Nsubjects_test, 'UniformOutput', false), ...
            arrayfun(@(x) sprintf('Test_S%d_g2', x), 1:Nsubjects_test, 'UniformOutput', false)]';
test_Target = [ones(Nsubjects_test, 1); zeros(Nsubjects_test, 1)];

T_test = table(test_IDs, test_Target, 'VariableNames', {'ID', 'Target'});
writetable(T_test, 'ClinicalLabels_test.xlsx');
fprintf('Created ClinicalLabels_test.xlsx with %d test labels\n', numel(test_IDs));

fprintf('\n All datasets created successfully!\n');
end