function [ ret ] = m_removecomplexzero( r )
    %M_REMOVENANINF remove NaN and Inf in data input
    %   this function replace nan and inf with interpolated data
    
    cz = r == complex( 0, 0 );
    x = 1:length(r);
    
    ret = r;
    for i = find(sum(cz) > 0)
        ret(cz(:, i)) = interp1(x(~cz(:,i)), r(~cz(:,i), i), find(cz(:, i)));
    end
    
    % even after interpolation, there might still have 0+0i,
    cz = (ret == complex( 0, 0 ));
    ret(cz) = complex( 0.1, 0.1 );

end

