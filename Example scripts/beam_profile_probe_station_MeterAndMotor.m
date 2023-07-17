%% initiate motor controller and the power meter

addpath("D:\InstrControl-MATLAB\Thorlabs Powermeter\");
addpath("D:\InstrControl-MATLAB\Thorlabs Motors\");

if ~exist('MC','var')
    MC = BSC102('70826550');
elseif ~MC.device.IsConnected
    MC = BSC102('70826550');
end

PMList = ThorlabsPowerMeter;
DeviceDescription = PMList.listdevices;
PM = PMList.connect(DeviceDescription, 1);
PM.setPowerAutoRange(1);
pause(5);

%% construct axes

% This is the axis given to the motor controller. Device unit is mm
x_min = 40;
x_max = 60;
step = 1;
x_num = round((x_max - x_min)./step + 1);

x_ax = linspace(x_min, x_max, x_num); % units in mm. step size is (max-min)/(n-1);

wait_stabilize = 20; % wait time after each motor move for power reading to stabilize.
n_avg = 100; % number of averages to take for the power meter reading 

power_measured = zeros(size(x_ax));

for i = 1:length(x_ax)
    MC.MoveTo(1, x_ax(i));
    disp( ['Current location: ', num2str(x_ax(i))  ] );
    pause(wait_stabilize); % pause for power reading to stabilize.
    
    power_reading = 0;
    for j = 1:n_avg
        PM.updateReading(0.1);
        power_reading = power_reading + PM.meterPowerReading; % meterPowerReading in W
    end
    power_measured(i) = power_reading ./ n_avg;
end

plot(x_ax, power_measured);

PM.disconnect;