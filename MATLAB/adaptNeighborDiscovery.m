clc(); close("all"); clear();

c = 3e8; % speed of light

% Parameters
beamwidth = 0.5 : 0.5 : 20;

d = 9.5 : 18; % radius of room -> 18 meters

controlPacketSize = 25 * 8; % bits
dataPacketSize    = 64000 * 8;

dataRates = [157.4, 210.2, 315.4] * 1e9;

nNodes = 50;
nSectors = ceil(2 * pi ./ deg2rad(beamwidth));

T_ia = 200e-6;

T_prop = d / c; % propagation delay across different distances.
T_cts = controlPacketSize / min(dataRates);
T_ack = T_cts;
T_cta = T_cts;
T_rts = T_cts;
T_bo_max = 10e-9;
T_data = dataPacketSize / mean(dataRates);
T_tx = T_cts + T_data + T_ack + 2 * mean(T_prop);
T_wait = 2 * T_cts +  T_bo_max  + 2 * max(T_prop);

p = nSectors * T_wait / (T_ia - nNodes * T_tx); % System load.

T_cycle_avg  = nSectors * T_wait + nNodes * p * T_tx;
T_cycle_avg2 = T_cycle_avg + nSectors * 2e-6;

figure();
plot(beamwidth, T_cycle_avg * 1e3); hold("on");
plot(beamwidth, T_cycle_avg2 * 1e3); grid("on");
xlabel("Antenna Beamwidth [deg]");
ylabel("Time [ms]");
legend("0 Beam Steering Latency", "2 us Beam Steering Latency");
