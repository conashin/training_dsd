//time unit: ns
//frequency unit: Hz
//This code is for even number students,which means the direction of LEDs' movement is from left to right.
//author: zhe yuan Liu

#include <iostream>
#include <iomanip>
#include <windows.h>
#define MAXTIME 200
#define SLEEPTIME 200
using namespace std;

void sim(int init_idx,string LEDs,int fre,int move,int mode);
int binTodec(string b);
int main()
{
               //"00011110"
    string input="00111111";//set your input here
    //input:8bits
    //input[0]:reset
    //input[1]:speed 0 -> 1Hz / 1 -> 2Hz
    //input[2]:pair 0 -> move one / 1 -> move two
    //input[3:6]:initial position (4bits) 0111=7
    //input[7]:inversion 0 -> light up / 1 -> light out

    int freq=input[1]=='1'? 2 :1;//Hz
    int move=input[2]=='1'? 2 :1;//LED
    int mode=input[7]=='1'? 0 :1;//mode==1 -> light up / mode==0 -> light out
    string str_init_pos=input.substr(3,4);//0111
    string LEDs="0000000000000000";

    int int_init_idx=binTodec(str_init_pos);

    sim(int_init_idx,LEDs,freq,move,mode);

    return 0;
}

//simulate LED operations
void sim(int init_idx,string LEDs,int freq,int move,int mode)
{
    cout<<endl;
    cout<<"init_idx: "<<init_idx<<endl;
    cout<<"freqency: "<<freq<<endl;
    cout<<"move: "<<move<<endl;
    cout<<"mode: ";
    if(mode==1)
    cout<<"light up"<<endl;
    else
    cout<<"light out"<<endl;

    int idx=init_idx;

    for(int cur_time=0;cur_time<=MAXTIME;cur_time+=freq)
    {

        if(LEDs=="0000000000000000" || LEDs=="1111111111111111")
        cout<<"-----------------------------------"<<endl;

        cout<<"#"<<cur_time<<setw(10)<<"LED: ";

        if(LEDs=="0000000000000000" || LEDs=="1111111111111111")
        {
            idx=init_idx;
            LEDs=mode?"0000000000000000":"1111111111111111";
            LEDs[init_idx]=mode?'1':'0';
            idx+=1;
        }
        else
        {
            if(move==1)
            LEDs[idx%16]=(mode==1)?'1':'0';
            else if(move==2)
            {
                LEDs[idx%16]=(mode==1)?'1':'0';
                LEDs[(idx+1)%16]=(mode==1)?'1':'0';
            }
            else
            {
                cout<<"error!!!"<<endl;
                exit(3);
            }

            idx+=move;
        }

        cout<<LEDs;
        //cout<<"  next idx= "<<idx;

        cout<<endl;

        Sleep(SLEEPTIME);
    }

}

//helper function
int binTodec(string b)
{
    int tot = 0;
    for (char bit : b)
    {
        tot = (tot << 1) + (bit - '0');
    }
    return tot;
}
