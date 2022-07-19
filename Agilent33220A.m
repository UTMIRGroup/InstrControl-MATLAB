classdef Agilent33220A
    % Agilent 33220A Function generator
    % Up to 20 MHz
    % This one has the quirk that low level = 0 isn't actually 0 but more like -76 mV
    
    %% Properties
    properties
        instr_handle
    end
    
    %% Methods
    methods
        %% Initialize
        function obj = Agilent33220A(instr_address)
            % Open the instrument at the given address
            try
                % need to change these lines
%                 obj.instr_handle = visa('ni','USB0::0x0957::0x0407::0123456789::INSTR');
                obj.instr_handle = visa('ni',instr_address);
%                 obj.instr_handle.InputBufferSize = 20000;
                fopen(obj.instr_handle);
                disp('Agilent 33220A connected successfully');
            catch ME
                disp(ME.message);
            end
        end
        
        %% Measurements
        function SetHiLevel(obj, value)
            message = ['VOLT:HIGH ',num2str(value)];
            obj.write(message);
        end
        
        function SetLoLevel(obj, value)
            message = ['VOLT:LOW ',num2str(value)];
            obj.write(message);            
        end
        
        function SetFrequency(obj, value)
            message = ['FREQ ', num2str(value)];
            obj.write(message); 
        end
        
        function OutputOn(obj)
            message = ['OUTP ON'];
            obj.write(message);
        end
        
        function OutputOff(obj)
            message = ['OUTP OFF'];
            obj.write(message);
        end
        
        %% Wrapped queries
        function querySetting(obj)
            Mode = obj.query('FUNC?');
            Freq = str2num(obj.query('FREQ?'));
            VoltLow = str2num(obj.query('VOLT:LOW?'));
            VoltHigh = str2num(obj.query('VOLT:HIGH?'));
            disp('Current settings are:')
            disp(['Mode =  ', Mode(1:end-1)]);
            disp(['Freq = ', num2str(Freq),' Hz']);
            disp(['Set voltage = ', num2str(VoltLow), ' V - ', num2str(VoltHigh), ' V']);
        end
        
        
        function queryVoltage(obj)
            VoltLow = str2num(obj.query('VOLT:LOW?'));
            VoltHigh = str2num(obj.query('VOLT:HIGH?'));
            message = ['Set voltage = ', num2str(VoltLow), ' V - ', num2str(VoltHigh), ' V'];
            disp(message);
        end
        
        %% Utilities
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
            disp('Agilent 33220A instr handle closed');
        end
    end
end