function [bit, z1_s, z2_s] = get_survivors(z1_window, z2_window, bits_window)
if all(bits_window(:,1) == bits_window(1,1)) % all states agree
        bit = bits_window(1,1);
        z1_s = z1_window(1,1);
        z2_s = z2_window(1,1);
    else % There is a disagreement among the states  
        counts = hist(bits_window(:,1).', [0,1]);
        if counts(1) >= counts(2) % 0 >= 1
            bit = 0;
        else                      % 1 > 0
            bit = 1;
        end
        index = find(bits_window(:,1) == bit, 1);
        
        z1_s = z1_window(index(1),1);
        z2_s = z2_window(index(1),1);
    end
end

