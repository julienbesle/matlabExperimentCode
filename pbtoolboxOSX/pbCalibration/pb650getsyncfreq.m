function syncFreq = pb650getsyncfreq
% syncFreq = pb650getsyncfreq
%
% Measure sync frequency for source.  Returns
% empty if can't sync.
%

global g_serialPort;

% Check for initialization
if isempty(g_serialPort)
   error('Meter has not been initialized.');
end

% Initialize
timeout = 30;

% Flushing buffers.
% fprintf('Flush\n');
dumpStr = '0';
while ~isempty(dumpStr)
	dumpStr = pb650serialread;
end


% Make measurement
% fprintf('Measure\n');
SerialComm('write', g_serialPort, ['f' char(10)]);

waited = 0;
inStr = [];
while isempty(inStr) && (waited < timeout)
	WaitSecs(1);
	waited = waited + 1;
	inStr = PR650serialread;
end
if waited == timeout
	error('No response after measure command');
end

% Pick up entire buffer.  This is the loop referred to above.
readStr = inStr;
while ~isempty(inStr)
	inStr = pb650serialread;
	readStr = [readStr inStr];
end

% Parse return
qual = -1;
[raw, count] = sscanf(readStr,'%f,%f',2);
if count == 2
	qual = raw(1);
	syncFreq = raw(2);
end

if qual ~= 0
	syncFreq = [];
end
