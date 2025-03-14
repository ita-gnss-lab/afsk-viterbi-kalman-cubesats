function [all_phases,odd_phases,even_phases] = get_phases(h)

all_phases = wrapToPi((0:11)*(pi*h));
even_phases = wrapToPi(all_phases(1+2*(0:5)));
odd_phases = wrapToPi(all_phases(2+2*(0:5)));
end