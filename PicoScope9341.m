classdef PicoScope9341
    % Picoscope 9341-25
    
    %% Properties
    properties
        h % The COM Server handle that talks to PicoSample3
    end
    
    %% Methods
    methods
        %% Initialize
        function obj = PicoScope9341
            try
                obj.h = actxserver('PicoSample3.COMRC');
                disp('COM server handle initiated');
                obj.h.ExecCommand('header off');
            catch ME
                disp(ME.message);
            end
        end
        
        %% Channel Settings
        function ChannelDisplay(obj, ch, mode)
            % Turn channel display on/off
            for i = 1:length(ch) % array operation?!
            CommandStr = ['Ch', num2str(ch(i)), ':Display ', mode];
            obj.h.ExecCommand(CommandStr);
            end
        end
        
        function ChannelAcquisition(obj, ch, mode)
            % Turn channel background acquisition on/off
            % On: always acquiring; Off: only acquire when channel display is on.
            % Might be a performance saver?
            for i = 1:length(ch)
            CommandStr = ['Ch', num2str(ch(i)), ':AcqOnlyEn', mode];
            obj.h.ExecCommand(CommandStr);
            end
        end
        
        function ChannelScale(obj, ch, scale)
            Command = ['Ch',num2str(ch),':Scale ', num2str(scale)]; % V/div
            obj.h.ExecCommand(Command);
        end
        
        function ChannelMode(obj, ch, mode)
            Command = ['Acq:Ch',num2str(ch),':Mode ',mode];
            obj.h.ExecCommand(Command);
        end
        
        function ChannelAverage(obj, ch, avg)
            Command = ['Acq:Ch',num2str(ch),':NAvg ', num2str(avg)];
            obj.h.ExecCommand(Command);
        end
        
        function ChannelEnvelopeCount(obj, ch, env)
            Command = ['Acq:Ch',num2str(ch),':NEnv ', num2str(env)];
            obj.h.ExecCommand(Command);
        end
        
        function ChannelRecLength(obj, ch, RecLen)
            Command = ['Acq:Ch', num2str(ch), ':RecLen ', num2str(RecLen)];
            obj.h.ExecCommand(Command);
        end
        
        %% Timebase Settings
        function TBMode(obj, mode)
            % Timebase modes: A (main), AB (Intensified), B(delayed)
            obj.h.ExecCommand(['TB:Mode ',mode]);
        end
        
        function TBScaleA(obj, scale)
            obj.h.ExecCommand(['TB:ScaleA ',num2str(scale)]);
        end
        
        function TBScaleB(obj, scale)
            obj.h.ExecCommand(['TB:ScaleB ',num2str(scale)]);
        end
        
        function Delay(obj, delay)
            obj.h.ExecCommand(['TB:Delay ', num2str(delay)]);
        end
        
        %% Trigger Settings
        function TriggerSource(obj, source)
            % acceptable sources: ExtDirect, ExtPrescaler, Ch1Direct, Ch2Direct, IntClock, Auxiliary
            obj.h.ExecCommand(['Trig:Source ',source]);
        end
        
        function TriggerLevel(obj, level)
            % Only works for External Direct trigger mode
            obj.h.ExecCommand(['Trig:ExtDir:Level ', num2str(level)]);
        end
        
        %% Measurements
        function [data_array] = ReadWav(obj)
            wav_raw = obj.h.ExecCommand('Wfm:Data?');
%             wav_raw = wav_raw(10:end);
            data_split = strsplit(wav_raw,',');
            data_array = str2double(data_split);
        end
        
        function t = TimeAxis(obj)
            ChLen = str2double(obj.h.ExecCommand('Wfm:Preamb:Poin?'));
            XOrg = str2double(obj.h.ExecCommand('Wfm:Preamb:XOrg?'));
            XInc = str2double(obj.h.ExecCommand('Wfm:Preamb:XInc?'));
            t = (0:(ChLen-1))*XInc + XOrg;
        end
        
        function Clear(obj)
            obj.h.ExecCommand('*ClrDispl');
        end
        
        
        %% Close
        function close(obj)
            release(obj.h);
            disp('COM server handle released');
        end
        
        
    end
end