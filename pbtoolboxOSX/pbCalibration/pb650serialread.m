function serialData = pb650serialread
% serialData = pb650serialread
%
% Reads data off the serial port until there is nothing left.  Returns an
% empty matrix if there is nothing to read.

global g_serialPort;

% Look for any data on the serial port.
serialData = char(SerialComm('read', g_serialPort))';

% If data exists keep reading off the port until there's nothing left.
if ~isempty(serialData)
    tmpData = 1;
    while ~isempty(tmpData)
        WaitSecs(0.050);
        tmpData = char(SerialComm('read', g_serialPort))';
        serialData = [serialData, tmpData];
    end
end