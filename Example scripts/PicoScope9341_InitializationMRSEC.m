% This is a sample script for initializing the PicoScope when doing a typical experiment at the MRSEC lab, for
% example, using the OPA to measure detector time response. 
%
% Typically, only a single channel is used, synchronized to a fixed trigger signal, and the signal delay with 
% regard to the trigger is, relatively, a constant value from day to day. Therefore, a lot of the repeated
% settings can be automated to save time. 
%{
This potentially also allows you to run PicoScope like other instruments, where you'd open an instance and
close it again at the end of each script. 
For other instruments, usually the measurement script looks something like the following:
DCSource = SomeSource(address1); Scope = SomeScope(address2); ...... (a bunch of measurements)......
DCSource.close; Scope.close; (so the handles are fully released).

The PicoScope is different since it uses a COMM server, so Scope = PicoScope9341; opens an instance of the
PicoSample software which does the talking. If you do a Scope.close at the end of each script, all the
initialization settings will be lost and it's a PITA if you try to configure everything again manually.
So, you'd either have to intialize the scope manually and separately, or incorporate some sort of automated
initialization into the script (one use of this sample script).
%}


Scope = PicoScope9341; % Opening the PicoSample instance.

Scope.ChannelDisplay([2,3,4], 'off'); % First deal with the other channels
Scope.ChannelAcquisition([2,3,4], 'off');

Scope.TriggerSource('ExtDirect');
Scope.TriggerLevel(800e-3); % 800 mV for the positive trigger coming from OPA XB7

Scope.TBMode('B');
Scope.TBScaleA(50e-9); % 50 ns/div
Scope.TBScaleB(2e-9); % 1 ns/div. Change this later to whatever suits your signal.
Scope.Delay(314e-9); % delay, can be 280~400 ns; zoom out to find signal

Scope.ChannelScale(1, 2e-3); % Set Ch1 to 2mV/div;
Scope.ChannelMode(1, 'AvgStab');
Scope.ChannelAverage(1, 4096);
Scope.ChannelRecLength(1, 8192);