dire = 'data/track/los4m_*_counterclockwise_other*err.mat';

fileList=dir(dire);  

cnt=0;
totalerr = [];
for i=1:length(fileList)
    fname = fileList(i).name;
    if strcmp(fname,'.')==1 || strcmp(fname,'..')==1
        continue;
    else
        load(fname);
        totalerr = [totalerr; err];
        cnt = cnt + 1;
    end
end

disp([num2str(cnt), ' files processed.']);