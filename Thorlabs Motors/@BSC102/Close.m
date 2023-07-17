function Close(obj)
    % close the Thorlabs Kinesis device connection
    if obj.device.IsConnected
        obj.device.Disconnect;
    end
end