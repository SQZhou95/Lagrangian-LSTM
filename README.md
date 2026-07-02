# Lagrangian-LSTM-for-aerosol-prediction-and-driver-analysis
This repository contains MATLAB code for developing a Lagrangian LSTM framework to predict aerosol concentrations and to interpret the trained model. The workflow includes air-mass trajectory calculation, input data extraction along trajectories, model development, and model interpretation.

The main scripts are organized as follows:

    1_Trajectory_calculation_and_read\
        traj_calulation: Calculates backwardairmass trajectories using the HYSPLIT model.
        traj_read: Reads trajectory output files and organizes them into MATLAB cell arrays for each year.
    2_Input_data_extraction\
        traj_data_organize: Organizes trajectory data and determines the land–ocean flag (flag_Land; 0 = ocean, 1 = land) for each trajectory point.
        MERRA_data_along_traj_10day: Extracts meteorological and aerosol-related variables from the MERRA-2 reanalysis along each airmass trajectory.
        DMS_data_along_traj_10day: Extracts sea-surface dimethyl sulfide (DMS) concentrations along each airmass trajectory.
        Chla_data_along_traj_10day: Extracts sea-surface chlorophyll-a concentrations along each airmass trajectory, accounting for airmass dispersion.
        SO2EM_data_along_traj_10day: Extracts SO2 emission flux data along each airmass trajectory, accounting for airmass dispersion.
        PREC_data_along_traj_10day: Extracts GPM precipitation rate data along each airmass trajectory, accounting for airmass dispersion.
    3_Model_development\
        LSTM\LSTM_grid_search_resampled_MCCV: Performs hyperparameter grid search for the LSTM model.
        LSTM\LSTM_trainining_resampled_MCCV: Trains an ensemble of LSTM models using the optimal hyperparameter combination.
        Traditional_models\*_grid_search: Conducts hyperparameter grid search for each traditional machine learning model.
        Traditional_models\*_training: Trains each traditional machine learning model using the selected optimal hyperparameters.
    4_Model_interpretation\
        GSA_Sobol_indice: Calculates the feature importance (Sobol’ indice) of each input variable to both total target variability and intramonthly variability.
        GSA_for_monthly_variation: Calculates the feature importance (Sobol' indice) of each input variable for the intermonthly variability of the target variable.
        GSA_time_series: Investigates the temporal evolution of feature importance along airmass trajectories for each input variable.

To run these scripts, MATLAB Statistics and Machine Learning Toolbox and Deep Learning Toolbox are required.

Please feel free to contact Shengqian Zhou (shengqian@wustl.edu) for any questions regarding the code.
