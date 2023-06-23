classdef Keithley2460
    % Keithley 2460 Sourcemeter, based on class file for 2420
    % 2460 is set to use TSP commands, and so will this class file 
    % Switching between TSP and SCPI is possible but involves rebooting the instrument, 
    % which can make things inconsistent)
    %
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
                % need to change these lines
%                 obj.instr_handle = visa('ni','USB0::0x2A80::0x1102::MY59282614::INSTR');
                obj.instr_handle = visa('ni',instr_address);
%                 obj.instr_handle.InputBufferSize = 20000;
                fopen(obj.instr_handle);
                disp('Keithley 2460 connected successfully');
                obj.write('*RST');
            catch ME
                disp(ME.message);
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

        function current = DCIV(obj, bias, n_avg)
            % take a DC IV sweep for input bias
            current = zeros(size(bias));
            obj.write(['trigger.model.load("SimpleLoop",' , num2str(n_avg)  , ')']);
            
            for i = 1:length(bias)
                DC.write(['smu.source.level = ', num2str(bias(i))]);
                DC.on;
                DC.write('trigger.model.initiate()');
                DC.write('waitcomplete()');
                pause(0.1);
                
                DC.off;
                DC.write('voltage = defbuffer1.sourcevalues');
                DC.write('current = defbuffer1');
                % output_bias =textscan(...
                %     DC.query(['printbuffer(1, ', num2str(n_avg),', voltage)']), ...
                %     '%f', 'Delimiter', ',');
                % output_bias = output_bias{1};
                output_current = textscan(...
                    DC.query(['printbuffer(1, ', num2str(n_avg),', current)']), ...
                    '%f','Delimiter', ',');
                output_current = output_current{1};
                current(i) = sum(output_current)/length(output_current);
            end
            
            DC.write('smu.source.level = 0');  % reset level to 0 to be safe
            DC.on;
            DC.write('trigger.model.initiate()');
            DC.write('waitcomplete()');
            pause(0.1);
            DC.off;
            
        end
        
        function on(obj)
            obj.write('smu.source.output = smu.ON');
        end
        
        function off(obj)
            obj.write('smu.source.output = smu.OFF');
        end
        
        %% Utility
        function write(obj,message)
            fprintf(obj.instr_handle,message);
        end
        
        function output = read(obj)
            output = fscanf(obj.instr_handle);
        end
        
        function output = query(obj, message)
            % Query anything using commands from the manual
            fprintf(obj.instr_handle,message);
            output = fscanf(obj.instr_handle);
        end

        function close(obj)
            fclose(obj.instr_handle);
            disp('Keithley 2460 instr handle closed');
        end
    end
end