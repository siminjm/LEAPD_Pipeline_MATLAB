# LEAPD Pipeline (MATLAB)
This repository provides a unified MATLAB-based framework for EEG preprocessing, feature extraction, classification, and correlation using the LEAPD (Linear Predictive Coding-based EEG Analysis for Prognosis and Diagnosis) method. It supports both binary classification tasks, such as predicting mortality (Deceased vs. Living subjects), and correlation analyses, including assessing associations between LEAPD scores and clinical measures such as MoCA or UPDRS. The pipeline is designed to be modular, reproducible, and research-friendly.

The framework includes optional EEG preprocessing using EEGLAB and ICLabel, with capabilities for detecting and removing noisy channels, applying ICA-based artifact rejection (blink, muscle, cardiac), performing line noise removal (60 Hz notch filtering), and visualizing raw versus cleaned EEG recordings. The processed EEG signals are automatically exported to the /cleaned_data/ folder for further analysis.

The core LEAPD analysis pipeline performs automatic parameter search over filter ranges and LPC orders. It supports both single- and multi-channel analysis (1–10 channels), cross-validation, and out-of-sample testing. For correlation-based analyses, polarity alignment is applied to ensure consistent interpretation of LEAPD scores relative to clinical outcomes.

Performance evaluation includes a comprehensive set of statistical metrics, such as ACC, AUC, SEN, SPC, PPV, NPV, Odds Ratio, LR⁺, Spearman’s rho, and corresponding p-values. The repository also includes result storage, report generation, and visualization utilities to support analysis, interpretation, and reproducibility.

The folder structure is organized as follows:

```
LEAPD_Pipeline_MATLAB/
├── Preprocessing/                   # EEG artifact removal module
│   ├── Demo.m
│   ├── pipeline_preprocessing.m
│   ├── detect_noisy_channels.m
│   ├── remove_line_noise.m
│   ├── cleaned_data/
│   └── README.md
│
├── main_train.m                     # LEAPD training script
├── main_test.m                      # LEAPD testing script
├── plot_results.m                   # Visualization
├── leapd_demo.m
│
├── +utils/                          # Helper functions
│   ├── load_data.m
│   ├── filter_data.m
│   ├── create_filter.m
│   ├── compute_yw.m
│   ├── build_hyperplanes.m
│   ├── compute_leapd_scores.m
│   ├── evaluate_classification.m
│   ├── evaluate_correlation.m
│   ├── combine_scores.m
│   ├── generate_combinations.m
│   ├── pick_polarity_and_rho.m
│   ├── read_labels_table.m
│   ├── fetch_targets.m
│   ├── count_subjects.m
│   └── save_results.m
│
├── results/
│   ├── train_results/
│   └── test_results/
│
├── README.md
├── LICENSE
└── .gitignore
```

To run preprocessing, you can navigate to the `/Preprocessing` folder and execute `Demo.m`, or use the function directly as:

```matlab
[X_clean, labels_clean, report, savePath] = pipeline_preprocessing(X_raw, Fs, labels);
```

The training phase is initiated using:

```matlab
cfg = struct;
cfg.mode        = "classification";    % or "correlation"
cfg.data_train  = "data/EEG_train.mat";
cfg.labels_file = "data/ClinicalLabels.xlsx";   % columns: ID, Target
cfg.save_dir    = "results/train_results";
results_train = main_train(cfg);
```

The testing (out-of-sample evaluation) is performed using:

```matlab
cfg2 = struct;
cfg2.mode            = "correlation";         
cfg2.data_test       = "data/EEG_test.mat";
cfg2.trained_model   = "results/train_results/BestParamsAll.mat";
cfg2.labels_file     = "data/ClinicalLabels_Test.xlsx";
cfg2.combo_sizes     = 1:10;
cfg2.max_full_combos = 5;
cfg2.save_dir        = "results/test_results";
results_test = main_test(cfg2);
```

Due to clinical confidentiality agreements, the original EEG datasets cannot be shared publicly. However, the full pipeline, algorithms, and code structure are provided to fully support reproducibility. All stages—from preprocessing to LEAPD evaluation—can be executed using synthetic or anonymized EEG data.

Key skills demonstrated in this pipeline include MATLAB-based EEG signal processing, ICA and noise/artifact removal, LPC feature extraction, distance-based hyperplane modeling, statistical evaluation using classification and correlation metrics, and reproducible, modular design for scientific workflows.

Developed by **Simin J Visser**, Ph.D. Candidate in the Departments of Electrical & Computer Engineering (ECE) and Neurology at the University of Iowa.

If you use this pipeline in academic or research work, please cite:

> Jamshidi, S., et al. (Year).
> *EEG-Based Mortality and Cognitive Decline Prediction in Parkinson’s Disease using the LEAPD Method.*
> Departments of Electrical & Computer Engineering (ECE) and Neurology, University of Iowa.
> (Preprint or Journal Reference — to be updated)

Released under the **MIT License with citation request**. See LICENSE for details.
