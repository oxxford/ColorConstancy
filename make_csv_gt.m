% This script generates csv file that is used for network training

path = './data/RGB_xy_samsung/';

res = {};
% traverse directory
files = dir(path);
% remove . and .. from the list
files = files(3:length(files));

%%visualization
% hold on;

for i=1:length(files)
    file = files(i);
    data = load(strcat(path, file.name));

    l = length(file.name);
    % filename of the image (used in training)
    name = strcat(file.name(7:l-4), '_cropped.tif');
    res{i, 1} = name;

    % write 18 colourful patches (their numbers are 1-18)
    for j=1:18
        ch = get_xy(data.xy_RGB(j, :));   
        res{i, 2*j} = num2str(ch(1));
        res{i, 2*j + 1} = num2str(ch(2));

%% visualization
%         color = [data.xy_RGB(j, 3)/255, data.xy_RGB(j, 4)/255, data.xy_RGB(j, 5)/255];
%         color = [ch(1), ch(2), 1 - ch(1) - ch(2)];
%         scatter(ch(1), ch(2), 25, color, 'filled')
    end

    % add gray patch (it's number is 21)
    gray_patch_index = 21;
    ch = get_xy(data.xy_RGB(gray_patch_index, :));  
    res{i, 2*19} = num2str(ch(1));
    res{i, 2*19 + 1} = num2str(ch(2));
end

%% visualization
% xlim([0 1])
% ylim([0 1])
% xlabel('r') 
% ylabel('g') 
% title('Chromaticity distribution samsung')

writecell(res, './data/target_samsung.csv')

function [res] = get_xy(patch_data)
    s = patch_data(3) + patch_data(4) + patch_data(5);
    x = patch_data(3) / s;
    y = patch_data(4) / s;

    res = [x, y];
end