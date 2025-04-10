clc(); close("all"); clear();

c = 3e8; % speed of light

% Parameters
d = 9.5 : 18; % radius of room -> 18 meters

controlPacketSize = 25 * 8; % bits
dataPacketSize    = 64000 * 8;

dataRates = [157.4, 210.2, 315.4] * 1e9;

nNodes = 50;
nSectors = 30;

interArrivalTimeList = (130 : 10 : 1000) * 1e-6;

T_prop = d / c; % propagation delay across different distances.
T_cts = controlPacketSize / min(dataRates);
T_ack = T_cts;
T_cta = T_cts;
T_rts = T_cts;
T_bo_max = 10e-9;
T_data = dataPacketSize / mean(dataRates);
T_tx = T_cts + T_data + T_ack + 2 * mean(T_prop);
T_wait = 2 * T_cts +  T_bo_max  + 2 * max(T_prop);

S_Results = [];

tCycleMax = nSectors * T_wait + nNodes * T_tx;
t = 1e-9 : 1e-7 : tCycleMax;

for k = 1 : numel(interArrivalTimeList)
    T_ia = interArrivalTimeList(k);
    p = nSectors * T_wait / (T_ia - nNodes * T_tx); % System load.

    n = 0 : nNodes;

    P_n = zeros(1, numel(n)); % probability of n transmission

    f_T_cycle  = zeros(1, numel(t)); % PDF of t_cycle
    f_T_face   = zeros(1, numel(t)); % PDF of t_face
    f_T_wait   = zeros(1, numel(t)); % PDF of t_wait
    f_T_sector = zeros(1, numel(t)); % PDF of t_sector
    t_cycle_n  = zeros(1, nNodes);   % Cycle Time over different n transmissions

    % Compute T_face
    for i = 1 : numel(n)
        % Compute Probability of n transmissions
        P_n(i) = nchoosek(nNodes, n(i)) * (1 - p) ^ (nNodes - n(i)) * p ^ n(i);
        % Compute Cycle Time based on Number of Transmissions
        t_cycle_n(i) = nSectors * T_wait + n(i) * T_tx + nSectors * 2e-6;
        % Find the closest match in your time axis {t} to the computed T_cycle value
        [~, idx] = min(abs(t - t_cycle_n(i)));
        f_T_cycle(idx) = f_T_cycle(idx) + P_n(i);
    end
    for i = 1 : numel(n)
        [~, idx2] = min(abs(t - t_cycle_n(i)));
        f_T_face(1 : idx2) = f_T_face(1 : idx2) + (ones(1, numel(f_T_face(1 : idx2))) .* f_T_cycle(idx2));
    end
    area = trapz(t, f_T_face);
    f_T_face = f_T_face ./ area;

    % T - Wait Time:
    f_T_wait(1) = 1 - p;
    f_T_wait    = f_T_wait + f_T_cycle .* p;
    f_T_wait    = f_T_wait ./ trapz(t, f_T_wait);

    % T - Sector Time
    distance_MCS  = [18, 17.6, 9.5];
    data_rate_MCS = [157.4, 210.2, 315.4] * 1e9;

    MCS_P_m = 1 / numel(distance_MCS); % Probability of m out of M {doing a 1/M}

    for i = 1 : numel(distance_MCS)
        t_prop2 = 3 * distance_MCS(i) / c;
        t_data2 = dataPacketSize / data_rate_MCS(i);
        arg     = T_wait + t_prop2 + T_cts + t_data2 + T_ack;
        [~, idx2] = min(abs(t - arg));
        f_T_sector(1, idx2) = f_T_sector(1, idx2) + MCS_P_m;
    end

    f_T_sector = f_T_sector ./ trapz(t, f_T_sector);

    f_t_conv = conv(f_T_face, f_T_wait);
    f_t_conv = f_t_conv ./ sum(f_t_conv);
    f_t_conv = conv(f_t_conv,f_T_sector);
    f_t_conv = f_t_conv ./ sum(f_t_conv);

    % T_Success:
    big_k = 10;
    P_b = [0.1, 0.4, 0.7, 0.9, 0.98, 0.999999999999999];
    T_cycle_avg = nSectors * T_wait + nNodes * p * T_tx ;
    S_temp = [];
    for P_b_index = 1 : numel(P_b)
        f_T_success  = zeros(1, numel(t));
        f_t_conv2 = [];
        for small_k = 0 : big_k
            scale_constant = (1 - P_b(P_b_index)) ^ (small_k - 1) * P_b(P_b_index);
            [~, idx3] = min(abs(t - T_cycle_avg * small_k));
            f_T_success(1 : idx3) = f_T_success(1 : idx3) + scale_constant;
        end
        f_T_success = f_T_success ./ trapz(t, f_T_success);
        f_t_conv2 = conv(f_t_conv, f_T_success);
        f_t_conv2 = f_t_conv2 ./ sum(f_t_conv2);
        S=0;
        for i = 1 : numel(t)
            S = S + dataPacketSize / t(i) * f_t_conv2(i);
        end
        S_temp = [S_temp, S];
    end
    S_Results = [S_Results, S_temp.'];
end

figure();
for i = 1 : size(S_Results, 1)
    plot(interArrivalTimeList * 1e6, S_Results(i, :) / 1e9);
    hold("on");
end
title("Throughput [Gbps] Accross different Inter-arrival Time");
grid("on");
xlim([min(interArrivalTimeList * 1e6), max(interArrivalTimeList * 1e6)]);
ylim([0, 40]);
legend("P_{LoS} = 0.1", "P_{LoS} = 0.3", "P_{LoS} = 0.5", "P_{LoS} = 0.7", "P_{LoS} = 0.9", "P_{LoS} = 0.98", "P_{LoS} = 1");
