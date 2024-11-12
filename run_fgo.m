%% Run factor graph optimization for smartphone's GNSS and IMU integration
% Author Taro Suzuki
clear classes; clear; close all; clc;
addpath ./functions/

P = py.sys.path;
modpath = "/home/rtk/Desktop/works/MatRTKLIB/+rtklib/";
if count(P,modpath) == 0
	insert(P,int32(0),modpath);
end
modpath = "/home/rtk/.local/lib/python3.8/site-packages";
if count(P,modpath) == 0
	insert(P,int32(0),modpath);
end
mod0 = py.importlib.import_module('rtkcmn');
py.importlib.reload(mod0);
mod1 = py.importlib.import_module('ephemeris');
py.importlib.reload(mod1);

%% Setting
% Initialization flag for position estimation.
% If you want to estimate without using the results of the previous estimation,
% set this to true. In that case, the graph optimization will be executed three times.
initflag = false;

% Target dataset: "train" or "test"
dataset = "test";

%% Read setting.csv
datapath = "./dataset_2023/"+dataset+"/";

% Read setting.csv
settings = readtable("./dataset_2023/settings_"+dataset+".csv", "TextType","string");
n = height(settings);  % Number of trip

% Collecting optimization status
optStat = repmat(struct("OptTime",NaN,"OptIter",NaN,"OptError",NaN,"Score",NaN), n, 1);

%% Run FGO
tic;
% Use parfor to speed up. The figure will not be displayed
for i=1:n
    disp(i);
    % Trip path
    setting = settings(i,:);
    trippath = datapath+setting.Course+"/"+setting.Phone+"/";

    %% FGO using GNSS+IMU (final estimation)
    % Estimate a more accurate position using the previous estimated result
    % (result_gnss_imu.mat) as input.
    if ~exist(trippath+"/result_gnss_imu.mat", "file")
        error("Please execute fgo_gnss_imu(datapath, setting, true) first!")
    end
    optStat(i) = fgo_gnss_imu(datapath, setting, false);
end
toc;

%% Write results to file
resultpath = "./results/"+dataset+"/";
[mScore, resultpath] = write_results(resultpath, settings, optStat);

% Show mean score (train dataset)
if contains(dataset, "train")
    fprintf("Mean score = %.4f m\n", mScore);
end

% Create submission file (test dataset)
if contains(dataset, "test")
    submission(resultpath, settings);
end