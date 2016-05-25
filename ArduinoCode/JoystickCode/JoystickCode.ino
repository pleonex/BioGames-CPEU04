/* Modified from Philip Vallone
2-axis joystick connected to an Arduino Micro
to output 4 pins, up, down, left & right
If you are using pull down resistors, change all the HIGHs to LOWs and LOWs to HIGH.
This skectch is using pull up resistors.
*/

/*Currently LEDs light up for 400 ms (Delay on bottom)
This can be altered to check effect.
Also, the LEDs are connected to PWM Arduino pins,
so you can change the code to alter their strength. 
*/

int UD = 0;
int LR = 0;
/* Arduino Micro output pins*/
int DWN = 11;
int UP = 10;
int LEFT = 9;
int RT = 6;
/* Arduino Micro Input Pins */
int IUP=A0;
int ILR=A1;

int MID = 10; // 10 mid point delta arduino, use 4 for attiny
int LRMID = 0;
int UPMID = 0;
void setup(){

  pinMode(DWN, OUTPUT);
  pinMode(UP, OUTPUT);
  pinMode(LEFT, OUTPUT);
  pinMode(RT, OUTPUT);

  digitalWrite(DWN, HIGH);
  digitalWrite(UP, HIGH);
  digitalWrite(LEFT, HIGH);
  digitalWrite(RT, HIGH);

  //calabrate center
  LRMID = analogRead(ILR);
  UPMID = analogRead(IUP);
}

void loop(){

  UD = analogRead(IUP);
  LR = analogRead(ILR);
  // UP-DOWN
  if(UD < UPMID - MID){
   digitalWrite(DWN, HIGH);
  }else{
   digitalWrite(DWN, LOW);
  }

  if(UD > UPMID + MID){
   digitalWrite(UP, HIGH);
  }else{
   digitalWrite(UP, LOW);
  }
  // LEFT-RIGHT
  if(LR < LRMID - MID){
   digitalWrite(LEFT, HIGH);
  }else{
   digitalWrite(LEFT, LOW);
  }

  if(LR > LRMID + MID){
   digitalWrite(RT, HIGH);
  }else{
   digitalWrite(RT, LOW);
  }

  delay(400);


}
