classdef Keithley2460
    % Keithley 2460 Sourcemeter, based on class file for 2420
    % 2460 is set to use TSP commands, and so will this class file 
    % Switching between TSP and SCPI is possible but involves rebooting the instrument, 
    % which can make things inconsistent)
    
    %% Properties
    properties
        instr_handle
    end
    
    %% Methods
    methods
        %% Initialize
        function obj = Keithley2460(instr_address)
            % Open the instrument at the given address
            try
%                 visadev is MATLAB's new visa connection interface introduced in R2021a
                obj.instr_handle = visadev(instr_address);
%                 obj.instr_handle.InputBufferSize = 20000;
                disp('Keithley 2460 connected successfully');
                obj.write('*RST');
            catch ME
                disp(ME.message);
                if strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
                    disp('If visadev doesn''t exist, check MATLAB version. Needs to be above R2021a')
                end
            end
        end
        
        %% Measurements
        function SetupDCIV(obj)
            obj.write('reset()')
        %a bunch of setup stuff
            obj.write('smu.measure.func = smu.FUNC_DC_CURRENT')
            obj.write('smu.source.func = smu.FUNC_DC_VOLTAGE')
            obj.write('smu.measure.terminals = smu.TERMINALS_FRONT')
            obj.write('smu.measure.sense = smu.SENSE_2WIRE')
            obj.write('smu.measure.autorange = smu.ON')
            obj.write('smu.measure.nplc = 1')
            obj.write('smu.source.highc = smu.OFF')
            obj.write('smu.source.autorange = smu.ON')
            obj.write('smu.source.readback = smu.ON')
        end

        function SetVoltage(obj, voltage)
            obj.write(['smu.source.level = ', num2str(voltage)]);
        end

        function SetCurrentLimit(obj, current_limit)
            obj.write(['smu.source.ilimit.level = ',num2str(current_limit)]);
        end

        function current = ReadCurrent(obj,n_avg)
            if nargin == 1 % if n_avg isn't inputed
                n_avg = 1; % default no averaging
            end
            
            obj.write(['trigger.model.load("SimpleLoop",' , num2str(n_avg)  , ')']);
            obj.on;
            obj.write('trigger.model.initiate()');
            obj.write('waitcomplete()');
%             obj.off;

            obj.write('current = defbuffer1');
            output_current = textscan(...
                obj.query(['printbuffer(1, ', num2str(n_avg),', current)']), ...
                '%f','Delimiter', ',');
            output_current = output_current{1};
            current = sum(output_current)/length(output_current);
        end
        
        function current = DCIV(obj, bias, n_avg)
            % take a DC IV sweep for input bias
            current = zeros(size(bias));
            obj.write(['trigger.model.load("SimpleLoop",' , num2str(n_avg)  , ')']);
            
            for i = 1:length(bias)
                obj.write(['smu.source.level = ', num2str(bias(i))]);
                obj.on;
                obj.write('trigger.model.initiate()');
                obj.write('waitcomplete()');
                pause(0.1);
                
                obj.off;
                obj.write('voltage = defbuffer1.sourcevalues');
                obj.write('current = defbuffer1');
                % output_bias =textscan(...
                %     DC.query(['printbuffer(1, ', num2str(n_avg),', voltage)']), ...
                %     '%f', 'Delimiter', ',');
                % output_bias = output_bias{1};
                output_current = textscan(...
                    obj.query(['printbuffer(1, ', num2str(n_avg),', current)']), ...
                    '%f','Delimiter', ',');
                output_current = output_current{1};
                current(i) = sum(output_current)/length(output_current);
            end
            
            obj.write('smu.source.level = 0');  % reset level to 0 to be safe
            obj.on;
            obj.write('trigger.model.initiate()');
            obj.write('waitcomplete()');
            pause(0.1);
            obj.off;

        end
        
        function on(obj)
            obj.write('smu.source.output = smu.ON');
        end
        
        function off(obj)
            obj.write('smu.source.output = smu.OFF');
        end
        
        %% Utility
        function write(obj,message)
            obj.instr_handle.write(message);
        end
        
        function output = read(obj)
            output = obj.instr_handle.readline;
        end
        
        function output = query(obj, message)
            % Query anything using commands from the manual
            obj.instr_handle.write(message);
            output = obj.instr_handle.readline;
        end

        function close(obj)
            delete(obj.instr_handle);
            disp('Keithley 2460 instr handle closed');
        end
    end
end