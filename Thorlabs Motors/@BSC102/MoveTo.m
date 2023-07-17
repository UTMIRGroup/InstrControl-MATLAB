function MoveTo(obj, channel, position, timeout)
% Move a motor to an absolute position
% Usage: 
% MC.MoveTo(1, 50, 60000);  % Move first channel to 50 mm with a timeout wait time of 60000 ms

if nargin == 3
    % if timeout is not specified, give it a default of 60000
    timeout = 60000;
end

ch = obj.device.GetChannel(channel);

% initialize the motor configs
if ~ch.IsMotorSettingsValid
    ch.LoadMotorConfiguration(ch.DeviceID);
end

if ~ch.IsEnabled
    ch.StartPolling(250);
    ch.EnableDevice;
    pause(0.5);
end

ch.MoveTo(position, timeout);

while ch.IsDeviceBusy end % wait out the busy period to prevent weird things

end