{
  Platform: Parallax Project USB Board
  Revision: 1.0
  Author: Yu Yi
  Date: 18 Nov 2021
  Log:
    Date: Desc
    18/11/2021: Creating object file for Comm Control

}
CON
        commRxPin = 20
        commTxPin = 21
        commBaud = 9600

        commStart = $7A

VAR  'Global Variable

  long CommID, CommStack[128]  ' cogID and space for cog
  long _Ms_001

OBJ  'Objects
  Comm      : "FullDuplexSerial.spin" 'UART communication for remote control



PUB Start(mainMSVal,RxRead)

    _Ms_001 := mainMSVal

    StopCore

    CommID := cognew(Comms(RxRead), @CommStack)

    return

PUB Comms(RxRead) | Value, tempValue, pastValue


  comm.Start(commTxPin, commRxPin, 0, commBaud)
  Pause(3000)

  tempValue := pastValue := 0
  repeat
    'rxValue := Comm.RxCheck >  Will check for byte but not wait.
    'rxValue := Comm.Rx > Wait at this statement for a byte, does not continue if it does not.
    'Comm.RxFlush
    value := Comm.Rx
    if (Value == commStart) 'If value read is commStart
        tempValue := Comm.Rx  'Holds value read in tempvalue
        ifnot tempValue == pastValue   ' Checks if temp value is unique from the past value
          pastValue := tempValue       ' Updates new past value when read value is unique
          long[RxRead] := pastValue    ' Deference RxRead and assign pastValue to it.

PUB StopCore  ' Stop the code in the core/cog and release the core/cog
    if CommID
      cogstop(CommID~)


PRI Pause(ms) | t
  t := cnt - 1088   ' sync with system counter
  repeat (ms #> 0)  ' delay must be >0
    waitcnt(t += _Ms_001)
  return