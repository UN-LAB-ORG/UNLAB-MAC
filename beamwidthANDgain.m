clc;
close all;
clear;

f = 130e9;
G = [1:2:80];

beamwidth = sqrt((4*pi)./(10.^(G./10)));
lambda = 3e8 / f;
diameter = (1.22 * lambda) ./beamwidth;
w_0 = diameter./2;
z_r = (pi.*(w_0).^2) ./ lambda;

max_Distance = [1;5;10;15;20]; 
w_z = w_0 .* sqrt(1 + (max_Distance./z_r).^2);

figure;
plot(G, w_z);
legend('1-meter', '5-meter', '10-meter','15-meter','20-meter')
xlabel('Gain [dBi]');
ylabel('Diameter of Beam [m]');
grid on;
% title("Diameter of Beam at Varying Distances and Antenna Gain");
figure;
plot(G, rad2deg(beamwidth));
xlabel('Gain [dBi]');
ylabel('Antenna Beamwidth [deg]')
% title("Antenna Beamwidth with Varying Gain Values");
grid on;