function ret = process(dire, fname)
    
    lambda = 3e8/5.24e9;
    debug = false;

    load([dire, 'config.mat']);    

    rx = [r1 r2 r3];        % three RXs

    % read CSI data
    try
        [time1, pc1, ~] = m_getcsi([dire, fname, '-1']);
        [time2, pc2, ~] = m_getcsi([dire, fname, '-2']);
        [time3, pc3, samp_rate] = m_getcsi([dire, fname, '-3']);
    catch
        disp('error reading CSI data');
        ret = -1;
        return;
    end

    % cut three CSI data to the same length
    [pc1, pc2, pc3, time] = align_time3(time1, time2, time3, pc1, pc2, pc3);


    skip_silence = 1.4;

    % get Doppler frequency shift (in Hz)
    [speed1, score1] = mimo2speed(pc1, samp_rate);
    [speed2, score2] = mimo2speed(pc2, samp_rate);
    [speed3, score3] = mimo2speed(pc3, samp_rate);

    % convert to speed (in m/s)
    movespeed1 = speed1 * lambda;
    movespeed2 = speed2 * lambda;
    movespeed3 = speed3 * lambda;
    speed = [movespeed1,movespeed2,movespeed3];
    score = [score1, score2, score3];

    % for data plot purpose
    [~,index]=min(score,[],2);
    %index=round(movmean(index,500));
    len=size(score);
    sel1=false(len(1),1);
    sel2=false(len(1),1);
    sel3=false(len(1),1);
    for i=1:len(1)
        if ceil(index(i))==1
            sel1(i)=true;
        end
        if ceil(index(i))==2
            sel2(i)=true;
        end
        if ceil(index(i))==3
            sel3(i)=true;
        end
    end 

    if debug
    figure;
    set(gcf,'Name','Doppler Frequency Shift');
    ax1=subplot(3,1,1); plot(time, movespeed1); hold on; line([0 time(end)], [0 0]); movespeed1(sel1)=NaN; plot(time, movespeed1','r'); title('speed observed @ RX1'); xlabel('time (s)'); ylabel('speed (m/s)');
    ax2=subplot(3,1,2); plot(time, movespeed2); hold on; line([0 time(end)], [0 0]); movespeed2(sel2)=NaN; plot(time, movespeed2','r'); title('speed observed @ RX2'); xlabel('time (s)'); ylabel('speed (m/s)');
    ax3=subplot(3,1,3); plot(time, movespeed3); hold on; line([0 time(end)], [0 0]); movespeed3(sel3)=NaN; plot(time, movespeed3','r'); title('speed observed @ RX3'); xlabel('time (s)'); ylabel('speed (m/s)');
    ax = [ax1 ax2 ax3];
    linkaxes(ax);

    figure;
    set(gcf,'Name','Rx Score')
    ax1=subplot(3,1,1); plot(time, score1); hold on; line([0 time(end)], [0 0]); score1(sel1)=NaN; plot(time, score1','r'); title('RX1 score'); xlabel('time (s)'); ylabel('score');
    ax2=subplot(3,1,2); plot(time, score2); hold on; line([0 time(end)], [0 0]); score2(sel2)=NaN; plot(time, score2','r'); title('RX2 score'); xlabel('time (s)'); ylabel('score');
    ax3=subplot(3,1,3); plot(time, score3); hold on; line([0 time(end)], [0 0]); score3(sel3)=NaN; plot(time, score3','r'); title('RX3 score'); xlabel('time (s)'); ylabel('score');
    ax = [ax1 ax2 ax3];
    linkaxes(ax);
    end

    skip = floor(skip_silence * samp_rate);
    if skip < 1
        skip = 1;
    end
    speed = speed(skip:end-150, :);
    score = score(skip:end-150, :);
    
    % calculate trajectory
    loc = trajectory_by_doppler_v3(speed, score, diff(time), initpoint, tx, rx, 10);
    
    % plot trajectory
    figure; 
    set(gcf,'Name','Trajectory')
    plotPolarColor(loc, fname);
    hold on; 
    plot(rx, 'diamond', 'color', 'red'); plot(tx, 'x');
    grid on;
    axis equal;
    
    text(real(tx) - 0.4, imag(tx), 'TX');
    for i = 1 : length(rx)
        text(real(rx(i)) - 0.2, imag(rx(i)) - 0.2, ['RX', num2str(i)]);
    end
    
    % set display axis range
    maxX = max(real([loc; tx; rx.'])) + 0.5;
    minX = min(real([loc; tx; rx.'])) - 0.5;
    maxY = max(imag([loc; tx; rx.'])) + 0.5;
    minY = min(imag([loc; tx; rx.'])) - 0.4;
    xlim([minX maxX]); ylim([minY maxY]);
    
    % overlap groundtruth
    if ~exist('groundtruth', 'var')
        return;
    end
    if trajectory_type
        line(real(groundtruth), imag(groundtruth), 'color', 'red', 'LineStyle', '--');
    else
        circle(groundtruth(1), groundtruth(2));
    end
    
    % save trajactory picture and location data
    try
        saveas(gcf, [dire, '/track/', fname], 'png');
        save([dire, '/track/', fname], 'loc');
    catch
        disp('cannot save figure');
    end
    
    ret = 0;
end


function [pc1, pc2, pc3, time] = align_time3(time1, time2, time3, pc1, pc2, pc3)
% align CSI data of three RXs
len = min([length(time1), length(time2), length(time3)]);
time = time1(1:len);

startlen=1;
for i = 1:numel(pc1)
    pc1{i} = pc1{i}(startlen:len, :);
    pc2{i} = pc2{i}(startlen:len, :);
    pc3{i} = pc3{i}(startlen:len, :);
end
end

function circle(centre, r)
    x = real(centre); y = imag(centre);
    rectangle('Position', [x-r, y-r, 2*r, 2*r], 'Curvature', [1, 1], 'edgecolor', 'red',  'LineStyle', '--');
    axis equal;
end
