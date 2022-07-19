classdef PAR5208
    % Princeton Applied Research 5208 lock-in amplifier
    
    %% Properties
    properties
        instr_handle
    end
    
    %% Methods
    methods
        %% Initialize
        function obj = PAR5208(instr_address)
            % Open the instrument at the given address
            try
                % need to change these lines
%                 obj.instr_handle = visa('ni','USB0::0x2A80::0x1102::MY59282614::INSTR');
                obj.instr_handle = visa('ni',instr_address);
%                 obj.instr_handle.InputBufferSize = 20000;
                fopen(obj.instr_handle);
                disp('PAR 5208 LIA connected successfully');
%                 obj.write('*RST');
            catch ME
                disp(ME.message);
            end
        end
        
        %% Measurements        
        function S = FindSensitivity(obj)
            SensitivityCode = str2double(obj.query('S'))+1;
            S_list = [5, 2, 1, ...
                0.5, 0.2, 0.1, ...
                50e-3, 20e-3, 10e-3, ...
                5e-3, 2e-3, 1e-3, ...
                500e-6, 200e-6, 100e-6, ...
                50e-6, 20e-6, 10e-6, ...
                5e-6, 2e06, 1e-6];
            S = S_list(SensitivityCode);
        end
        
        function SetSensitivityCode(obj, SensitivityCode)
            obj.write(['S ',num2str(SensitivityCode)]);
        end
        
        function [R, theta] = MeasureRTheta(obj)
            CurrentMode = str2double(obj.query('M'));
            if CurrentMode ~= 1
                obj.write('M 1');
            end
            S = obj.FindSensitivity;
            R = str2double(obj.query('Q1'))/2000*S;
            theta = str2double(obj.query('Q2'))/10;
        end
        
        %% Utility
        function write(obj,message)
            fprintf(obj.instr_handle,message);
            pause(0.1);
        end
        
        function output = read(obj)
            output = fscanf(obj.instr_handle);
            pause(0.1);
        end
        
        function output = query(obj, message)
            % Query anything using commands from the manual
            fprintf(obj.instr_handle,message);
            pause(0.1);
            output = fscanf(obj.instr_handle);
            pause(0.1);
        end

        function close(obj)
            fclose(obj.instr_handle);
            disp('PAR 5208 LIA instr handle closed');
        end
    end
end