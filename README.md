# LEAPD Pipeline (MATLAB)

Unified training, testing, and preprocessing framework for EEG-based classification using the LEAPD method. Developed by Simin Jamshidi, University of Iowa, Departments of Electrical & Computer Engineering (ECE) and Neurology.

## Overview

This repository provides a full MATLAB workflow for EEG analysis using the LEAPD (Linear Predictive Coding-based EEG Analysis for Prognosis and Diagnosis) approach.

It now includes: EEG Preprocessing module (EEGLAB + ICLabel) for artifact detection and cleaning, Training and testing modules for LEAPD-based classification.

The pipeline supports: Binary classification (e.g., Deceased vs Living subjects).

## Core Features

### Preprocessing
Optional preprocessing using EEGLAB and ICLabel, Automatic detection and removal of noisy channels, ICA-based artifact removal (blink, muscle, heart), Optional 60 Hz notch filter and harmonics suppression, Visualization of raw vs cleaned EEG signals, Automatic saving of cleaned EEG to /cleaned_data/.

To run the standalone preprocessing demo: cd Preprocessing then Demo.

You can also call it manually: [X_clean, labels_clean, report, savePath] = pipeline_preprocessing(X_raw, Fs, labels);

### LEAPD Pipeline
Automatic parameter search over filter bands and LPC orders, Single- and multi-channel evaluation (1–10 channels), Cross-validation and out-of-sample testing, Comprehensive metrics: ACC, AUC, SEN, SPC, PPV, NPV, OR, LR⁺.

## Repository Structure

LEAPD_Pipeline_MATLAB/
├── Preprocessing/                   # EEG artifact removal module
│   ├── Demo.m
│   ├── pipeline_preprocessing.m
│   ├── detect_noisy_channels.m
│   ├── remove_line_noise.m
│   ├── README.md
│   └── cleaned_data/
├── main_train.m                     # LEAPD training script
├── main_test.m                      # LEAPD testing script
├── plot_results.m                   # Visualization
├── leapd_demo.m                     # Complete classification demo
├── +utils/                          # Helper functions
│   ├── load_data.m
│   ├── filter_data.m
│   ├── create_filter.m
│   ├── compute_yw.m
│   ├── build_hyperplanes.m
│   ├── compute_leapd_scores.m
│   ├── evaluate_classification.m
│   ├── combine_scores.m
│   ├── generate_combinations.m
│   ├── read_labels_table.m
│   ├── fetch_targets.m
│   ├── count_subjects.m
│   ├── save_results.m
│   ├── create_datasets.m            # Synthetic data for classification
│   ├── detect_preprocessing_status.m
│   └── detect_additional_noisy_channels.m
├── results/
│   ├── train_results/
│   └── test_results/
├── README.md
├── LICENSE
└── .gitignore

## Quick Start

1. (Optional) Preprocessing: Run the preprocessing demo to remove noise and artifacts: 
cd Preprocessing
Demo
You can also call it manually: 
[X_clean, labels_clean, report, savePath] = pipeline_preprocessing(X_raw, Fs, labels);

2. Training (LEAPD): 
cfg = struct;
cfg.mode        = "classification";              % or "correlation"
cfg.data_train  = "data/EEG_train.mat";
cfg.labels_file = "data/ClinicalLabels.xlsx"; % columns: ID, Target
cfg.save_dir    = "results/train_results";

results_train = main_train(cfg);

3. Testing (Out-of-Sample): 
cfg2 = struct;
cfg2.mode            = "classification";          % or "correlation"          
cfg2.data_test       = "data/EEG_test.mat";
cfg2.trained_model   = "results/train_results/BestParamsAll.mat";
cfg2.labels_file     = "data/ClinicalLabels_Test.xlsx";
cfg2.combo_sizes     = 1:10;
cfg2.max_full_combos = 5;
cfg2.save_dir        = "results/test_results";

results_test = main_test(cfg2);

Complete Pipeline Demo: Run complete demonstration pipeline: 

% For classification (mortality prediction)
leapd_demo();

% For correlation (MoCA score prediction)  
leapd_demo_correlation();

% Generate synthetic data for classification
utils.create_datasets();

Create synthetic datasets for testing:

% Generate synthetic data with MoCA scores for correlation
utils.create_moca_datasets();

## Data Format

Your EEG data should be structured as: EEG: 1×C cell array, each containing {group1_data, group2_data}, Channel_location: 1×C cell array of channel names, Filenames: Struct with group1 and group2 subject IDs.

## Data Privacy Notice

Due to clinical confidentiality agreements, the original EEG datasets used in this research cannot be shared publicly. However, the entire analysis pipeline, algorithms, and reproducible code structure are fully provided to ensure transparency. All stages—from preprocessing to LEAPD evaluation—can be executed using synthetic or anonymized EEG data.

## Skills Demonstrated

MATLAB — advanced EEG signal processing and algorithm design, EEG Preprocessing — ICA, ICLabel, and noise/artifact removal, Feature Extraction — LPC coefficients and hyperplane distances, Statistical Analysis — classification metrics, AUC, OR, LR⁺, Reproducible Research — modular, documented, version-controlled workflow.

## Authors

Simin Jamshidi — Ph.D. Candidate, Departments of Electrical & Computer Engineering (ECE) and Neurology, University of Iowa.

Supervisors: Prof. Soura Dasgupta and Dr. Nandakumar Narayanan.

## Citation

If you use this pipeline in academic or research work, please cite: Jamshidi, S., et al. (Year). EEG-Based Mortality and Cognitive Decline Prediction in Parkinson's Disease using the LEAPD Method. Departments of Electrical & Computer Engineering (ECE) and Neurology, University of Iowa. (Preprint or Journal Reference — to be updated)

## License

Released under the MIT License (with Citation Request). See the LICENSE file for details.

For questions or technical support, please contact Simin Jamshidi at simin-jamshidi@uiowa.edu