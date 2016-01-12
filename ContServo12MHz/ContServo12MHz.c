   /*
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    */

// This programme is for control continious servo. The CPU runs on 12MHz crystal
#include <8051.h>
#define servoPin P1_0
#define dispDot P3_7
#define outputDC P3_5
void millisInterrupt(void) __interrupt 1;
void delay(unsigned int itime);
char valueTH0=0x00;
char valueTL0=0x00;
int PWMWidthMicroseconds = 2250; // It gives 6262 ms rotation time
/**************************************************************************/
void setup();
void loop();
void main(){
	setup();
	while(1)loop();
}
/**************************************************************************/

void setup(){
	valueTH0=(0xFF - PWMWidthMicroseconds) / 256;
	valueTL0=(0xFF - PWMWidthMicroseconds) % 256;
	//Initillazation of timer0
	TMOD=0x01;		//Timer 0 16-BIT Mode
	IE=0x82;		//Timer Interrupt0 with initial value 0000
	TR0=1;			//Start Timer0
	outputDC = 0;
}
void loop(){
	dispDot = ! dispDot;
	delay(500);
}
void millisInterrupt(void) __interrupt 1{	
	servoPin = ! servoPin;
	TH0=valueTH0;
	TL0=valueTL0;
}
void delay(unsigned int itime){
	unsigned int i,j;
	for(i=0;i<itime;i++)
		for(j=0;j<128;j++);
}