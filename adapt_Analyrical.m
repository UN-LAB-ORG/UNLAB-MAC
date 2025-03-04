clc;
close all;
clear;

f = 130e9;
c = 3e8; %speed of light

control_packet_size = 25 * 8;  % bits
data_packet_size    = 64000 * 8; 

d = 9.5:1:18; % radius of room -> 18 meters 
tprop = d./c; %propagation delay across different distances. 

tpropmax = max(tprop);

data_rates = [157.4, 210.2, 315.4]  .* 1e9;

min_data_rate = min(data_rates);
avg_data_rate = mean(data_rates);

T_cts = control_packet_size / min_data_rate;
T_ack = T_cts;
T_cta = T_cts;
T_rts = T_cts;
T_bo_max = 10e-9;

T_data = data_packet_size / avg_data_rate;

T_tx = T_cts + T_data + T_ack + 2*(mean(tprop));
T_wait = 2*(control_packet_size / min_data_rate) +  T_bo_max  + 2*tpropmax;

inter_arrival_time_list = (130:10:1000) .* 1e-6 ; 
S_Results = [];
N_sec = 30;
Nnodes = 50;

t_cycle_max = N_sec*T_wait + (Nnodes*T_tx);
t = 1e-9:1e-7:t_cycle_max;

for k = 1:length(inter_arrival_time_list)
    T_ia = inter_arrival_time_list(k);
    lambda_ = 1./T_ia; % packet rate
    p = (N_sec*T_wait) / ((T_ia - (Nnodes*T_tx))); % System load.
    
    n = 0:1:Nnodes;
   
    P_n = zeros(1,length(n)); % probability of n transmission
    
    f_T_cycle  = zeros(1,length(t)); % PDF of t_cycle
    f_T_face   = zeros(1,length(t)); % PDF of t_face
    f_T_wait   = zeros(1,length(t)); % PDF of t_wait
    f_T_sector = zeros(1,length(t)); % PDF of t_sector
    t_cycle_n  = zeros(1,Nnodes);    % Cycle Time over different n transmissions
    
    %% Compute T_face
    for i = 1:length(n)
        % Compute Probability of n transmissions
        P_n(i) = nchoosek(Nnodes,n(i))*((1-p)^(Nnodes-n(i))) * p^(n(i));
        % Compute Cycle Time based on Number of Transmissions 
        t_cycle_n(i) = (N_sec*T_wait) + (n(i)*T_tx) + (N_sec*2e-6);
        % Find the closest match in your time axis {t} to the computed T_cycle value
        idx = findClosestIndex(t , t_cycle_n(i));
        f_T_cycle(idx) = f_T_cycle(idx) + P_n(i);
    end
    for i = 1:length(n)
        idx2 = findClosestIndex(t , t_cycle_n(i));
        f_T_face(1:idx2) = f_T_face(1:idx2) + (ones(1,length(f_T_face(1:idx2))).*f_T_cycle(idx2));
    end
    area = trapz(t, f_T_face);
    f_T_face = f_T_face ./area;
 
    %% T - Wait Time: 
    f_T_wait(1) = (1-p);
    f_T_wait    = f_T_wait + (f_T_cycle.*p);
    
    area = trapz(t, f_T_wait);
    f_T_wait = f_T_wait ./area;



    %% T - Sector Time
    distance_MCS     = [18, 17.6, 9.5];
    data_rate_MCS    = [157.4, 210.2, 315.4] .* 1e9;

    MCS_P_m = 1/length(distance_MCS); % Probability of m out of M {doing a 1/M}
    
    for i = 1:length(distance_MCS)
        t_prop2 = 3* (distance_MCS(i) / c) ;
        t_data2 = data_packet_size/data_rate_MCS(i);
        arg     = T_wait + t_prop2 + T_cts + t_data2 + T_ack;
        idx2 = findClosestIndex(t , arg);
        f_T_sector(1,idx2) = f_T_sector(1,idx2) + MCS_P_m;
    end
    area = trapz(t, f_T_sector);
    f_T_sector = f_T_sector ./ area;


    f_t_conv = conv(f_T_face, f_T_wait);
    f_t_conv = f_t_conv ./ sum(f_t_conv);
    f_t_conv = conv(f_t_conv,f_T_sector);
    f_t_conv = f_t_conv ./ sum(f_t_conv);
    

    %% T_Success :
    big_k = 10;
    P_b = [0.1 0.4 0.7 0.9 0.98 0.999999999999999];
    T_cycle_avg = N_sec*T_wait + (Nnodes*p*T_tx);
    S_temp = [];
    for P_b_index = 1:length(P_b)
        f_T_success  = zeros(1,length(t));
        f_t_conv2 = [];
            for small_k = 0:big_k
                scale_constant = (1-P_b(P_b_index))^(small_k-1) * P_b(P_b_index);
                index_3 = findClosestIndex(t , T_cycle_avg*small_k);
%                 f_T_success(1:index_3) = f_T_success(1:index_3) ... 
%                     + (ones(1,length(f_T_success(1:index_3))).*scale_constant);
                f_T_success(1:index_3) = f_T_success(1:index_3) + scale_constant;
            end
            area = trapz(t, f_T_success);
            f_T_success = f_T_success ./area;
            f_t_conv2 = conv(f_t_conv,f_T_success);
            f_t_conv2 = f_t_conv2 ./ sum(f_t_conv2);
            S=0;
            for i = 1:length(t)
                S = S + ((data_packet_size/ t(i)) * f_t_conv2(i));
            end
            S_temp = [S_temp S];
    end
    S_Results = [S_Results S_temp'];
end

figure;
for i = 1:size(S_Results,1)
    plot(inter_arrival_time_list.*1e6, S_Results(i,:)/1e9);
    hold on;
end
title("Throughput [Gbps] Accross different Inter-arrival Time");
grid on;
xlim([min(inter_arrival_time_list*1e6) , max(inter_arrival_time_list*1e6)]);
ylim([0, 40]);
legend('P_{LoS} = 0.1' , 'P_{LoS} = 0.3' , 'P_{LoS} = 0.5', 'P_{LoS} = 0.7', 'P_{LoS} = 0.9' , 'P_{LoS} = 0.98' , ...
    'P_{LoS} = 1');
function idx = findClosestIndex(list, value)
    % Find the index of the closest value in the list
    [~, idx] = min(abs(list - value));
end