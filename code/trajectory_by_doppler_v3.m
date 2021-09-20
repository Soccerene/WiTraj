function [Loc, LocT, v]= trajectory_by_doppler_v3(move_speed, score, deltaT, initPos, Tx, Rx, window)
%% get trajectory from Doppler speeds
% input:	move_speed     Doppler speeds of Rx
%           score       score of Rx
%           deltaT          sample interval time
%           initPos         initial position of person
%           Tx              position of Tx (in complex value)
%           Rx              position of Rx (in complex vector)
%           window          input/output sample ratio
% output:   Loc             location sequence (in complex vector)
%           LocT            time sequence
%           v               human motion speed (in complex vector)

len = length(move_speed);
seg = floor(len/window);

v   = zeros(seg, 1);
Loc     = v;
LocT    = v;
deltaT=[0,deltaT];
curPos = initPos;
[~, min_score] = min(score, [], 2);



for i = 1:seg
    s = window * (i-1) + 1;
    e = s + window - 1;
    drop_antenna = round(mean(min_score(s:e)));
    ant = [];
    for j=1:3
        if j~= drop_antenna
            ant = [ant, j];
        end
    end

    ref_ang = angle(curPos - Tx);
    normal_dir1 = getnormaldir(Tx, Rx(ant(1)), curPos);
    normal_dir2 = getnormaldir(Tx, Rx(ant(2)), curPos);

    dopplermove_step = [sum(move_speed(s:e, ant(1)) .* deltaT(s:e)'), sum(move_speed(s:e, ant(2)) .* deltaT(s:e)')];
    proj = [cos(normal_dir1 - ref_ang), cos(normal_dir2 - ref_ang)];
    normal_step = dopplermove_step ./ proj / 2;
    newPos = gethumanspeed(curPos, [normal_dir1, normal_dir2], normal_step);
%     if (abs(newPos) ~=abs(1+1i))
%     disp('stop here');
%     end
    Loc(i) = curPos;
    v(i) = (newPos - curPos) / deltaT(i);
    if ~isnan(newPos)
        curPos = newPos;
    end
    LocT(i) = sum(deltaT(s:e));
end

LocT = cumsum(LocT);

end

function normal_dir = getnormaldir(tx, rx, pos)
% this function return the normal vector based on the location of tx, rx,
% and human target

    p1 = pos - tx;
    p2 = pos - rx;
    ang1 = angle(p1);
    ang2 = angle(p2);
    normal_dir = (ang1 + ang2) / 2;
    pos_x = pos + 0.01 * exp(1i * normal_dir);

    % deal with pi/-pi ambiguity
    if abs(tx - pos_x) + abs(rx - pos_x) < abs(p1) + abs(p2)
        normal_dir = normal_dir + pi;
    end

end

function newpos = gethumanspeed(pos, doppler_dir, doppler_move)
    
    % new pos based on each doppler
    if sum(abs(doppler_move)) == 0
        newpos = pos;
        return;
    end
    pos_x = pos + doppler_move(1) * exp(1i * doppler_dir(1));
    pos_y = pos + doppler_move(2) * exp(1i * doppler_dir(2));
    
    t1 = -1 / tan( doppler_dir(1) );
    t2 = -1 / tan( doppler_dir(2) );

    x = (imag(pos_x) - imag(pos_y) + t2 * real(pos_y) - t1 * real(pos_x)) / (t2 - t1);
    y = t1 * x + imag(pos_x) - t1 * real(pos_x);
    newpos = x + y * 1i;
    
end