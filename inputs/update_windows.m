function [z1_window, z2_window, bits_window] = update_windows(z1_window, z2_window, bits_window)
z1_window(:,1:end-1) = z1_window(:,2:end);
z2_window(:,1:end-1) = z2_window(:,2:end);
bits_window(:,1:end-1) = bits_window(:,2:end);
end

