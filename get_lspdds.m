function [spds_normalized]=get_lspdds( ...
    filename, ... % 'lspdd.json'
    normalize)
    % read json
    fid = fopen(filename); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    val = jsondecode(str);
    
    % preallocate space
    spds_formatted = zeros(81,length(val));
    wv = linspace(380, 780, 81);

    for i=1:length(val)
        curr_index = 1;
    
        spd = val(i).spectralData;
        for j=1:length(spd)
            x = spd(j);

            % if the current wavelength match with those that we want to
            % store - put it in the storage on the current index and
            % increment the index for storage
            if ismember(x.w, wv)
                spds_formatted(curr_index, i) = x.ri;
                curr_index = curr_index + 1;
            end
        end
    end
    
    if normalize
        % normalizing spd vectors (making their lenghts=1)
        spds_normalized = zeros(size(spds_formatted));
        for i=1:length(val)
            curr_spd = spds_formatted(:, i);
            spds_normalized(:, i) = curr_spd/sqrt(dot(curr_spd, curr_spd));
        end
    else
        spds_normalized=spds_formatted;
    end
end