classdef InstrumentName
    % A basic template for any NI-VISA instrument
    
    %% Properties
    properties
        instr_handle
    end
    
    %% Methods
    methods
        %% Initialize
        function obj = InstrumentName(instr_address)
            % Open the instrument at the given address
            try
                % need to change these lines
%                 obj.instr_handle = visa('ni','USB0::0x2A80::0x1102::MY59282614::INSTR');
                obj.instr_handle = visa('ni',instr_address);
%                 obj.instr_handle.InputBufferSize = 20000;
                fopen(obj.instr_handle);
                disp('Instrument connected successfully');
            catch ME
                disp(ME.message);
            end
        end
        
        %% Measurements
        
        
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
            disp('instr handle closed');
        end
    end
end