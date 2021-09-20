function [ time, rx, samp_rate] = m_getcsi( fname )
%M_GETCSI Summary of this function goes here
%   Detailed explanation goes here

csi_src = read_bf_file( fname );

csi = [csi_src{:}];     %turn cell to struct
len = length(csi);

timestamp = [csi.timestamp_low];
time = m_normTime( timestamp ); 
%disp('Boney time',time);
samp_rate = len / max(time);

disp(['read packets: ', num2str(len), ' @ fn = ', num2str(samp_rate)]);

ntx = csi.Ntx;
nrx = csi.Nrx;
agc = [csi.agc];

rssi = [csi.rssi_a; csi.rssi_b; csi.rssi_c];

% get scaled csi
c = zeros(len, ntx, nrx, 30);
for i=1:len
    c(i,:,:,:) = get_scaled_csi(csi(i));
end
%disp('csi scale process ok.');
%----------------------------

rx = cell(size(c,2),size(c,3));
for i=1:size(c,2)
    for j=1:size(c,3)
        %ra = [ra, abs(squeeze(c(:, i, j, :)))];
        r = squeeze(c(:, i, j, :));
        rx{i,j} = r;
    end
end


end

