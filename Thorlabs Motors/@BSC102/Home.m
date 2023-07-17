function Home(obj, channel)
% Home a specific motor channel. 
% Usage: 
% MC.Home(2);               % Homes the second channel
% MC.Home;                   % Same as MC.Home(1). If no parameters are given, assume channel 1.
% MC.Home(1, 60000);    % specifices the timeout to be 60000 ms

if nargin == 1
    % If no parameters are given, assume channel 1.
    ch = obj.device.GetChannel(1);
end

if nargin == 2
    ch = obj.device.GetChannel(channel);
end

% initialize the motor configs
if ~ch.IsMotorSettingsValid
    ch.LoadMotorConfiguration(ch.DeviceID);
end

if ~ch.IsEnabled
    ch.StartPolling(250);
    ch.EnableDevice;
    paue(0.5);
end

ch.Home(0); % use non-waiting methods to home the channel.

while ch.IsDeviceBusy end % wait out the busy period to prevent weird things

end