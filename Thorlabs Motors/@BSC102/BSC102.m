classdef BSC102
    % Thorlabs multichannel motor controllor
    % This version of MATLAB class for the Thorlabs motor controller is written using Thorlab's Kinesis .NET APIs 
    % since the old APT software (using ActX) is getting phased out of MATLAB. (Not to mention that, from dealing with
    % talking to Origin, ActX servers are rather hard to use...)
    % MC = BSC102;  % starts in sim mode
    % MC = BSC102('70826550');  % starts with actual device
    % MC = BSC102('70000001', 'sim');   % starts a specifc emulated device in sim mode.

    properties
        device
    end
    
    
    methods

        function obj = BSC102(serial_number, sim_flag)  %
            % load Thorlabs .dll files
            NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Benchtop.StepperMotorCLI.dll');
            NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
            NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');

            if nargin == 0
                % Constructor called without a serial number, going into simulation mode
                disp('Motor object called without a serial number, assuming starting in simulation mode');

                try 
                    Thorlabs.MotionControl.DeviceManagerCLI.SimulationManager.Instance.InitializeSimulations();
                    Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI.BuildDeviceList();
                    deviceList = Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI.GetDeviceList();
                catch ME
                    disp('Error found when initializing in simulation mode');
                    disp('Make sure Kinesis Simulator is open with emulated devices enabled');
                    disp(['Matlab error: ', ME.message]);
                end

                serial_number = cell(ToArray(deviceList));
                serial_number = serial_number{1};
                obj.device = Thorlabs.MotionControl.Benchtop.StepperMotorCLI.BenchtopStepperMotor.CreateBenchtopStepperMotor(serial_number);
                obj.device.Connect(serial_number);
                disp('Successfully started in sim mode');
            end

            if nargin == 1
                % Constructor called with one input parameter, should be the serial number in string
                try
                    Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI.BuildDeviceList();
%                     deviceList = Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI.GetDeviceList();
                    obj.device = Thorlabs.MotionControl.Benchtop.StepperMotorCLI.BenchtopStepperMotor.CreateBenchtopStepperMotor(serial_number);
                    obj.device.Connect(serial_number);
                    disp(['Successfully connected to device with SN: ', serial_number]);
                catch ME
                    disp('Error found when initializing');
                    disp(['Matlab error: ', ME.message]);
                end
            end


            if nargin == 2
                % Constructor called with two input parameter, should be the serial number but followed by a 'sim' flag
                if ~strcmp(sim_flag, 'sim')
                    disp('Error: second input parameter should only be ''sim'' to indicate a simulation flag!');
                    return 
                end
                try
                    Thorlabs.MotionControl.DeviceManagerCLI.SimulationManager.Instance.InitializeSimulations();
                    Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI.BuildDeviceList();
%                     deviceList = Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI.GetDeviceList();
                    obj.device = Thorlabs.MotionControl.Benchtop.StepperMotorCLI.BenchtopStepperMotor.CreateBenchtopStepperMotor(serial_number);
                    obj.device.Connect(serial_number);
                catch ME
                    disp('Error found when initializing');
                    disp(['Matlab error: ', ME.message]);
                end
                disp(['Successfully connected to emulated device with SN: ', serial_number]);
            end

        end
        
        EnableChannel(obj, channel)
        
        Home(obj, channel)

        MoveTo(obj, channel, position)
        
        Close(obj);

    end
end