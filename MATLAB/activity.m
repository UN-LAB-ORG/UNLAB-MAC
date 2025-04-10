clc(); close("all"); clear();

c = 3e8; % speed of light

% Parameters
beamwidth = [0.1, 3, 12];

d = 9.5 : 18; % radius of room -> 18 meters

controlPacketSize = 25 * 8; % bits
dataPacketSize    = 64000 * 8;

dataRates = [157.4, 210.2, 315.4] * 1e9;

nNodes = 50;
nSectors = 360 ./ beamwidth;

interArrivalTimeList = (150 : 50 : 1000) * 1e-6;

lambda_a = 0.05;
r = 18;
gamma_tx = 1;

T_prop = d / c; % propagation delay across different distances.
T_cts = controlPacketSize / min(dataRates);
T_ack = T_cts;
T_cta = T_cts;
T_rts = T_cts;
T_bo_max = 10e-9;
T_data = dataPacketSize / mean(dataRates);
T_tx = T_cts + T_data + T_ack + 2 * mean(T_prop);
T_wait = 2 * T_cts +  T_bo_max  + 2 * max(T_prop);

beamwidth_rad = deg2rad(beamwidth);
lengthsub = r ./ tan(pi / 2 - beamwidth_rad / 2);
area_t = 0.5 * 2 * lengthsub * r;

pdf_activity = zeros(numel(beamwidth_rad), numel(interArrivalTimeList));

for i = 1 : numel(beamwidth_rad)
    for j = 1 : numel(interArrivalTimeList)
        T_ia = interArrivalTimeList(j);
        p = nSectors(i) .* (T_wait + 2e-6) ./ (T_ia - (nNodes * T_tx)); % System load.
        sum_tx = 0;
        for k = 0 : 1 : nNodes
            temp  = (lambda_a * area_t(i)) .^ k .* exp(-lambda_a * area_t(i)) ./ factorial(k);
            temp2 = 1 - (1 - p) ^ (gamma_tx * k);
            sum_tx = sum_tx + temp * temp2;
        end
        pdf_activity(i, j) = sum_tx * (1 - exp(-lambda_a * area_t(i)));
    end
end

x = interArrivalTimeList * 1e6;
pdf_activity = pdf_activity.';

figure();
plot(x, pdf_activity(:, 1)); hold("on");
plot(x, pdf_activity(:, 2));
plot(x, pdf_activity(:, 3)); grid("on");
xlabel("Inter-Arrival Time [\mus]");
ylabel("Probability Of Uplink Transmission");
legend("0.1\circ", "3\circ", "12\circ");
