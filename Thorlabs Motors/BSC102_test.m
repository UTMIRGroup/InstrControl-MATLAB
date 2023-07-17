if ~exist('MC','var')
    MC = BSC102('70826550');
elseif ~MC.device.IsConnected
    MC = BSC102('70826550');
end

MC.MoveTo(1, 10);

% pause(0.1);

% MC.Home(1);

% MC.Close;