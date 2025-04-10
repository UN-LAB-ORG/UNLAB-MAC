clc(); close("all"); clear();

c = 3e8; % speed of light

% Parameters
f = 130e9;
G = 1 : 2 : 80;
maxDistance = [1; 5; 10; 15; 20];

lambda = c / f;
beamwidth = sqrt(4 * pi ./ (10 .^ (G ./ 10)));
diameter = 1.22 * lambda ./ beamwidth;
w0 = diameter / 2;
zR = pi * w0 .^ 2 / lambda;
w_z = w0 .* sqrt(1 + (maxDistance ./ zR) .^ 2);

figure();
plot(G, w_z); grid("on");
legend("1-meter", "5-meter", "10-meter", "15-meter", "20-meter");
xlabel("Gain [dBi]");
ylabel("Diameter of Beam [m]");

figure();
plot(G, rad2deg(beamwidth)); grid("on");
xlabel("Gain [dBi]");
ylabel("Antenna Beamwidth [deg]")
