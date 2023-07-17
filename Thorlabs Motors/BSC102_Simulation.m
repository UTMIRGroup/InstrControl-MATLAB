% This is a testing script for programming BSC203.
% Turn on Kinesis simulation first before progressing.

NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Benchtop.StepperMotorCLI.dll');
% NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Benchtop.StepperMotorUI.dll');
% NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManager.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');


% import Thorlabs.MotionControl.DeviceManagerCLI.*
% import Thorlabs.MotionControl.GenericMotorCLI.*
% import Thorlabs.MotionControl.Benchtop.StepperMotorCLI.*

Thorlabs.MotionControl.DeviceManagerCLI.SimulationManager.Instance.InitializeSimulations();
Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI.BuildDeviceList();
deviceList = Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI.GetDeviceList();

sn = cell(ToArray(deviceList));
sn = sn{1};

device = Thorlabs.MotionControl.Benchtop.StepperMotorCLI.BenchtopStepperMotor.CreateBenchtopStepperMotor(sn);
device.Connect(sn);

channel1 = device.GetChannel(1);

motorConfiguration = channel1.LoadMotorConfiguration(channel1.DeviceID);