%FMCW parameters

fc = 77e9;
c = 3e8;
lambda = c/fc;

%Sweep time 
%range_max = 200;
%tm = 5.5*range2time(range_max,c);
tm = 1e-3;

% The sweep bandwidth can be determined according to the range resolution
% and the sweep slope is calculated using both sweep bandwidth and sweep
% time.


sweep_slope = 7*10^12;


%Sampling frequency 
fs = 2e6;


%Sweep BW
bw = 1e05;



%FMCW signal
waveform = phased.FMCWWaveform('SweepTime',tm,'SweepBandwidth',bw,...
    'SampleRate',fs);

sig = waveform();
subplot(211); plot(0:1/fs:tm-1/fs,real(sig));
xlabel('Time (s)'); ylabel('Amplitude (v)');
title('FMCW signal'); axis tight;

%Radar system environment
ant_aperture = 6.06e-4;                         % in square meter
ant_gain = aperture2gain(ant_aperture,lambda);  % in dB

tx_ppower = db2pow(5)*1e-3;                     % in watts
tx_gain = 9+ant_gain;                           % in dB

rx_gain = 15+ant_gain;                          % in dB
rx_nf = 4.5;                                    % in dB

transmitter = phased.Transmitter('PeakPower',tx_ppower,'Gain',tx_gain);
receiver = phased.ReceiverPreamp('Gain',rx_gain,'NoiseFigure',rx_nf,...
    'SampleRate',fs);

car_dist = 45;
car_speed = 0;

cartarget = phased.RadarTarget('MeanRCS',0.001,'PropagationSpeed',c,...
    'OperatingFrequency',fc);
carmotion = phased.Platform('InitialPosition',[car_dist;0;0.5],...
    'Velocity',[car_speed;0;0]);

radar_speed = 25*1000/3600;
radarmotion = phased.Platform('InitialPosition',[0;0;0.5],...
    'Velocity',[radar_speed;0;0]);
channel = phased.FreeSpace('PropagationSpeed',c,...
    'OperatingFrequency',fc,'SampleRate',fs,'TwoWayPropagation',true);


    [radar_pos,radar_vel] = radarmotion(waveform.SweepTime);
    [tgt_pos,tgt_vel] = carmotion(waveform.SweepTime);

    sig = waveform();
    txsig = transmitter(sig);
    
    % Propagate the signal and reflect off the target
    txsig = channel(txsig,radar_pos,tgt_pos,radar_vel,tgt_vel);
    txsig = cartarget(txsig);
    
    txsig = receiver(txsig); 
   
    figure(2);
    plot(abs(txsig));


