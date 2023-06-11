% function to compare 2 spds (normalize, visualize and calculate SAM)
function compare_spds(spd1, spd2)
    spd1 = spd1 / sqrt(dot(spd1, spd1));
    spd2 = spd2 / sqrt(dot(spd2, spd2));

    fprintf('\n Sam %f \n', sam(spd1, spd2))

    hold on;
    plot(spd1)
    plot(spd2)
    legend('original', 'predicted')
end