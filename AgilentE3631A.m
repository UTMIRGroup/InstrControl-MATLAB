classdef AgilentE3631A
    % Agilent DC source borrowed from Prof. Jia's group
    
    %% Properties
    properties
        instr_handle
    end
    
    %% Methods
    methods
        function obj = AgilentE3631A(instr_address)
            % Open the instrument at the given address
            try
                % need to change these lines
%                 obj.instr_handle = visa('ni','USB0::0x2A80::0x1102::MY59282614::INSTR');
                obj.instr_handle = visa('ni',instr_address);
%                 obj.instr_handle.InputBufferSize = 20000;
                fopen(obj.instr_handle);
                disp('Agilent E3631A connected successfully');
            catch ME
                disp(ME.message);
            end
        end
        
        function Apply(obj,value)
            % only doing channel 1 for the time being
            fprintf(obj.instr_handle,['APPL P6V, ',num2str(value)]);
        end
        
        function I = ReadCurrent(obj)
            I = str2double(obj.query('MEAS:CURR?'));
        end
        
        function TurnOn(obj, varagin)
            if nargin==1
                channel = '1';
            elseif nargin==2
                channel = varagin(1);
                if channel == 1 || channel == 2 || channel == 3
                    channel = num2str(channel);
                else 
                    disp('Outside Channel Range!')
                end
            else
                disp('Too many input parameters! Only enter channel n#');
            end
            
            fprintf(obj.instr_handle, ['OUTP ON']); 
        end
        
        function TurnOff(obj, varagin)
            if nargin==1
                channel = '1';
            elseif nargin==2
                channel = varagin(1);
                if channel == 1 || channel == 2 || channel == 3
                    channel = num2str(channel);
                else 
                    disp('Outside Channel Range!')
                end
            else
                disp('Too many input parameters! Only enter channel n#');
            end
            
            fprintf(obj.instr_handle, ['OUTP OFF']); 
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
        end
    end
end