classdef PicoScope9341
    % Object class for communicating with Picoscope 9341-25 
    % Basic operations: 
    % Create object with Scope = PicoScope9341;
    % If a scope is connected via USB, the PicoSample3 software panel will open and be connected to the
    % physical scope. If a scope is not connected, the PicoSample3 software panel will open in simulation mode
    % (where you can test out new wrapper functions).
    % 
    % The fundamental way to send a command to the scope software is: 
    %              ReturnString = obj.h.ExecCommand(CommandString)
    % where obj is the scope class object, CommandString is the string that contains the command, and ReturnString is the
    % message returned by the scope software. This is simple enough that I don't want to create dedicated wrapper
    % functions like for the other instrument class files. CommandString follows the syntax used by the scope, which can
    % be found in the programmer's guide and seems very similar to the SCPI commands used by older instruments. 
    
    properties
        h % The COM Server handle that talks to PicoSample3
    end
    
    methods
        %% Utility functions
        function obj = PicoScope9341
            try
                obj.h = actxserver('PicoSample3.COMRC');
                disp('COM server handle initiated');
                obj.h.ExecCommand('header off');
            catch ME
                disp(ME.message);
            end
        end
        
        function close(obj)
            % Release the handle and closes the software panel
            if ishandle(obj.h)
                release(obj.h);
                disp('PicoSample3 COM server handle released');
            else
                disp('Handle invalid, might already be closed');
            end
        end
        
        function Settings = ChannelAcqInfo(obj, ch)
            % Retrieve the channel acquisition settings and save in a struct
            % Example: Settings = Scope.ChannelSettings(1);
            Settings = struct;
            
            Settings.Channel = ch;
%             Settings.VoltageScale   = obj.h.ExecCommand(['ch',num2str(ch),':scale?']);
%             Settings.VoltageOffset  = obj.h.ExecCommand(['ch',num2str(ch),':offset?']);
            
            AllParameters = obj.h.ExecCommand(['acq:ch',num2str(ch),'?']);
            SplitParameters = split(AllParameters,';');
            Settings.AcqMode = SplitParameters{1};
            Settings.RecordLength = str2double(SplitParameters{end});
            if size(SplitParameters,1)==4
                Settings.NAvg = str2double(SplitParameters{2});
            end
            
        end   
        
        function Settings = TimeInfo(obj)
            % Retrieve the time settings and save in a struct
            % Example: Settings = Scope.TimeSettings;
            Settings = struct;
           
            Settings.TimeScaleA     = obj.h.ExecCommand('TB:ScaleA?');
            Settings.TimeScaleB     = obj.h.ExecCommand('TB:ScaleB?');
            Settings.TimeDelay      = obj.h.ExecCommand('TB:Delay?');
            
            TriggerSource = obj.h.ExecCommand('Trig:Source?');
            if isequal(TriggerSource, 'EXTDIRECT')
            Settings.TriggerLevel   = obj.h.ExecCommand('Trig:ExtDir:Level?');
            end
                end
        
        %% Changing Channel Settings
        function ChannelDisplay(obj, ch, mode)
            % Turn channel display on/off
            % Example: Scope.ChannelDisplay([2,3,4], 'off');
            for i = 1:length(ch) % array operation?!
            CommandStr = ['Ch', num2str(ch(i)), ':Display ', mode];
            obj.h.ExecCommand(CommandStr);
            end
        end 
        
        function ChannelAcquisition(obj, ch, mode)
            % Turn channel background acquisition on/off
            % Example: Scope.ChannelDisplay(2:4, 'off');
            % On: always acquiring; Off: only acquire when channel display is on.
            % Might be a performance saver?
            for i = 1:length(ch)
            CommandStr = ['Ch', num2str(ch(i)), ':AcqOnlyEn', mode];
            obj.h.ExecCommand(CommandStr);
            end
        end
        
        function ChannelScale(obj, ch, scale) 
            % Set the scale of a selected channel to the desired value
            % Example: Scope.ChannelScale(1, 10e-3);
            % will set the scale of Ch1 to 10mV/div
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
        
        function AutoRescale(obj, ch)
            Waveform = obj.ReadWav;
            new_scale = round((max(Waveform) - min(Waveform))/3e-3);
            obj.ChannelScale(ch, new_scale*1e-3);
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
        function data_array = ReadWav(obj)
            % After a series of tests with strsplit, str2double, and sscanf, 
            % this seems to be the best configuration (textscan is fastest).
            % Wfm:Data? command speed is sort of inconsistent, sometimes 
            % it's 0.023s sometimes it's 0.012s, no idea what's the key factor
            wav_raw = obj.h.ExecCommand('Wfm:Data?');
            data_split = textscan(wav_raw,'%f','Delimiter',',');
            data_array = data_split{1}';
        end

        function data_array = ReadWavAvg(obj, n_avg)
            % Read n_avg numbers of consecutive waveforms and average over them
            % Can be used together with the scope's internal averages.
            wav_raw = obj.h.ExecCommand('Wfm:Data?');
            data_split = textscan(wav_raw, '%f', 'Delimiter',',');
            data_array = data_split{1}';
            for i = 2:n_avg
                wav_raw = obj.h.ExecCommand('Wfm:Data?');
                data_split = textscan(wav_raw, '%f', 'Delimiter',',');
                data_array = data_array + data_split{1}';
            end
            data_array = data_array/n_avg;
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
        
        
        
    end
end