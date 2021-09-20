

% directory of CSI data file
dire = '../WiTraj/data/diamond/';
% file name to be processed
fname = 'los4m_diamond_counterclockwise_t10';

if ~exist([dire, 'config.mat'], 'file')
    disp('no config.mat');
    return;
end

if ~exist([dire, 'track'], 'dir')
    mkdir([dire, 'track']);
end

process(dire, fname);
