function plotPolarColor(x, caption)
%PLOTPOLAR plot vectors

    title (gca, caption);
    len = length(x);
    temp = colormap(jet(len));
    t = 1:len;
    plot(x(1), 'h', 'Color', temp(1,:));
    hold on;
    for i = 2 : len
        plot(x(i),'.','Color', temp(i,:));
    end
    axis equal;
    xlabel('x (m)');
    ylabel('y (m)');
end


