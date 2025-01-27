 function keyPressed = pbGetKey(keysWanted,theKeyboard,flush)
 %
 %  function keyPressed = pbGetKey([keysWanted][,theKeyboard])
 %
 %  keysWanted	:   array of keys you are waiting for e.g, [124 125 kbName('space')] (defaults to 1:512) 
 %  theKeyboard :   keyboard index (defaults to 1)
 %
 %  keyPressed  :   index of the pressed key. Used KbName(keyPressed) to see key label
 %
 %  This routine calls clc to clear the command window after getting a key.
 %
 %  N.B. This routine does some checking to see if the keyboard index is
 %  valid, etc., so it may not be the fastest routine for getting a key
 %  press. The timing of this routine has not been checked.
 %
 %  History     :
 %  23-Oct-2006 :   Wrote it. -- PJB
 %
 
  if (exist('flush')==0)
      flush=0;
  end;
  
  kb = GetKeyboardIndices;
%   if (exist('theKeyboard')==0)|(length(kb)==1)
%       theKeyboard=kb(1);
%   end;
  if (exist('theKeyboard')==0)
      theKeyboard=max(kb(:));
  end;
  if (max(ismember(theKeyboard,kb))==0)
      error('pbGetKey: Illegal keyboard index');
  end;
  if(exist('keysWanted')==0)|(length(keysWanted)==0)
      keysWanted=1:512;
      WaitSecs(.1);
  end;

  if flush
      FlushEvents('keyDown');
  end;
  success = 0;
  while success == 0
    pressed = 0;
    while pressed == 0
        WaitSecs(0.001);
        [pressed, secs, kbData] = KbCheck(theKeyboard);
    end; % while pressed==0
    for i = 1:length(keysWanted)
        if kbData(keysWanted(i)) == 1
            success = 1;
            keyPressed = keysWanted(i);
              if flush
                  FlushEvents('keyDown');
              end;
            break;
        end; % if
    end; % for
      if flush
          FlushEvents('keyDown');
      end;
end; % while success==0
clc;
return;