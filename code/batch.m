% batch processing

% directory to be processed
dire = '../WiTraj/data/circle/';

fileList=dir(dire);  

if ~exist([dire, 'config.mat'], 'file')
    disp('no config.mat');
    return;
end

if ~exist([dire, 'track'], 'dir')
    mkdir([dire, 'track']);
end
        
cnt = 0;
for i=1:length(fileList)
    fname = fileList(i).name;
    if strcmp(fname,'.')==1 || strcmp(fname,'..')==1 || strcmp(fname,'config.mat')==1
        continue;
    else
        fname = fname(1:end-2);
        if ~isfolder([dire,fname])
            close all;
            process(dire, fname);
            disp(['scanning ', dire, fname]);
            cnt = cnt + 1;
        end
    end
end

disp([num2str(cnt), ' files processed.']);