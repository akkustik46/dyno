unit Unit3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, RTTICtrls, TAChartExtentLink, TAGraph, TASeries,
  TAFuncSeries, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, Types, TACustomSeries;

type

  { TForm3 }

  TForm3 = class(TForm)
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    Chart1LineSeries2: TLineSeries;
    Chart2: TChart;
    Chart2LineSeries1: TLineSeries;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    StatusBar1: TStatusBar;




    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form3: TForm3;
  runfile,tempstr: TStringList;
  mills: Tstrings;
  datastr: array of string;
  i,i2,count,oldrolt,oldengt,engrpm,maxrpm,t1,t2,t3,x,y,yt,w: integer;
  alpha,torque,omega,omegaold,rollrpm,maxtorque,power,maxpower: real;
  const
    //moi=4.11384196;
      moi=5.4E-7;
implementation
 uses Unit1;
{$R *.lfm}

 { TForm3 }

 procedure TForm3.FormCreate(Sender: TObject);
 begin

  //Open Run from file
  runfile:=TStringList.Create;
{  if Form1.butgraph=false then
     begin
     StatusBar1.Panels[0].Text:=workdir+'\'+Form1.bikemodel.caption+'\'+Form1.bikemodel.caption+'_'+Form1.datetime+'.run';
     runfile.LoadFromFile(workdir+'\'+Form1.bikemodel.caption+'\'+Form1.bikemodel.caption+'_'+Form1.datetime+'.run');
     end

  else
  begin    }
   StatusBar1.Panels[0].Text:=Form1.loadedfile;
   runfile.LoadFromFile(Form1.loadedfile);

  //end;
     if Form1.runstart_box.Caption='OFF' then
        begin
             Chart1.Extent.XMin:=1000;
             Chart2.Extent.XMin:=1000;
             maxrpm:=1000;
        end
           else
        begin
           Chart1.Extent.XMin:=StrToInt(Form1.runstart_box.Caption);
           Chart2.Extent.XMin:=StrToInt(Form1.runstart_box.Caption);
           maxrpm:=StrToInt(Form1.runstart_box.Caption);
        end;

  tempstr:=Tstringlist.Create;
   tempstr.Delimiter:=',';
   t1:=0;
  t2:=0;
  t3:=0;
  maxtorque:=0;
  maxpower:=0;
  omegaold:=0;
   // SetLength(datastr, 10);
  for i:=9 to (runfile.Count-1) do
  begin

   tempstr.Delimitedtext:=runfile[i];
   x:=StrToInt(tempstr[1]);
   t3:=StrToInt(tempstr[2]);
   yt:=StrToInt(tempstr[3]);
   y:=StrToInt(tempstr[4]);
   w:=StrToInt(tempstr[10]);
   if x<>0 then
      begin
      if  (t3=0) OR ((t3-t2)=0) then
          begin
             if ((t3-t2)=0) and ((x-xold)=0) then
               begin

                rollrpm:=0;
                omega:=0;
                alpha:=0;
                t1:=t2;
                t2:=t3;
                xold:=x;
               end;

                end
                else
                begin
                rollrpm:=(1/(t3/1000000))*(60/RollTooth);
                omega:=((2*pi)/RollTooth)/(t3/1000000);
                alpha:=((omega-omegaold)/(t3/1000000));
                  omegaold:=omega;
                  t1:=t2;
                  t2:=t3;
                  xold:=x;
                end;
      end
      else
      begin
      rollrpm:=0;
      end;
      if y<>0 then
         begin
         engrpmold:=engrpm;
         engrpm:=(60000000 div (y)) div StrToInt(Form1.cylinders.Caption) ;
         oldengt:=y;

            end
         else
         begin
            engrpm:=0;
            oldengt:=y;
          end;
      if engrpm>maxrpm then
         maxrpm:=engrpm;
   torque:=alpha*moi;
   power:=torque*omegaold;
   if torque>maxtorque then
      maxtorque:=torque;
   if power>maxpower then
      maxpower:=power;
   Label1.Caption:='Torque:'+FloatToStr(maxtorque);
   Label2.Caption:='Power:'+FloatToStr(maxpower);
  tempstr.Clear;
  end;
  Chart1.Extent.XMax:=maxrpm+500;
  Chart2.Extent.XMax:=maxrpm+500;
  if maxtorque>maxpower then
  Chart1.Extent.YMax:=maxtorque
  else
  Chart1.Extent.YMax:=maxpower;

  Chart2.Extent.YMax:=20;
  tempstr.Delimitedtext:=runfile[9];
  t1:=StrToInt(tempstr[2]);
  tempstr.Delimitedtext:=runfile[10];
  t2:=StrToInt(tempstr[2]);
  if (t2-t1)=0 then
     omegaold:=0
  else
      if t2<>0 then
  omegaold:=(1000000*6.28)/(t2);
  for i:=11 to (runfile.Count-1) do
  begin

   tempstr.Delimitedtext:=runfile[i];
    x:=StrToInt(tempstr[1]);
   t3:=StrToInt(tempstr[2]);
   yt:=StrToInt(tempstr[3]);
   y:=StrToInt(tempstr[4]);
   w:=StrToInt(tempstr[10]);
   if x<>0 then
      begin
      if  (t3=0) OR ((t3-t2)=0) then
          begin
             if ((t3-t2)=0) and ((x-xold)=0) then
               begin

                rollrpm:=0;
                omega:=0;
                alpha:=0;
                t1:=t2;
                t2:=t3;
                xold:=x;
               end;

                end
                else
                begin
                rollrpm:=(1/(t3/1000000))*(60/RollTooth);
                omega:=((2*pi)/RollTooth)/(t3/1000000);
                alpha:=((omega-omegaold)/(t3/1000000));
                  omegaold:=omega;
                  t1:=t2;
                  t2:=t3;
                  xold:=x;
                end;
      end
      else
      begin
      rollrpm:=0;
      end;
      if y<>0 then
         begin
         engrpmold:=engrpm;
         engrpm:=(60000000 div (y)) div StrToInt(Form1.cylinders.Caption) ;
         oldengt:=y;

            end
         else
         begin
            engrpm:=0;
            oldengt:=y;
          end;
    torque:=alpha*moi;
    power:=torque*omegaold;
//   Chart2LineSeries1.AddXY(engrpm,((5/1024)*w),'',clBlack);
    Chart2LineSeries1.AddXY(engrpm,(7.35+((((5/1024)*w)/5)*((22.39-7.35)/1))),'',clBlack);
   Chart1LineSeries1.AddXY(engrpm,power,'',clBlack);
   Chart1LineSeries2.AddXY(engrpm,torque,'',clBlack);

   Memo1.Append(FloatToStrF(torque,ffGeneral,3,5));
   {
   t3:=StrToInt(tempstr[1]);
      y:=
      Int(tempstr[3]);
      w:=StrToInt(tempstr[10]);
       if t3<>0  then
          begin
               if (t3-t2)<>0 then
                  begin
                    omega:=(1000000*6.28)/(t3-t2);
                    alpha:=omega-omegaold/((t3-t2)-(t2-t1));
                    omegaold:=omega;
                    t1:=t2;
                    t2:=t3;

                  end
               else
               begin
               alpha:=0;
               omegaold:=omega;
               t1:=t2;
               t2:=t3;
               end;
          end;

   if y<>0 then
         begin
         if(y-oldengt)<>0 then
            begin
            engrpmold:=engrpm;
         engrpm:=(60000000 div (y-oldengt)) div StrToInt(Form1.cylinders.Caption) ;
         oldengt:=y;
               if engrpm>maxrpm then
                  maxrpm:=engrpm;

            end
         else
         begin
            engrpm:=0;
            oldengt:=y;
         end;
         end
         else
         begin
         engrpm:=0;
         end;

     torque:=moi*alpha;
    Memo1.Append(FloatToStrF(torque,ffGeneral,3,5));
   Chart2LineSeries1.AddXY(engrpm,((5/1024)*w),'',clBlack);
   Chart1LineSeries1.AddXY(engrpm,torque,'',clBlack);
   }
   end;
  //Chart1LineSeries1.AddXY(1500,10,'',clBlack);
  //Chart1LineSeries1.AddXY(2000,50,'',clBlack);
  //Chart1LineSeries1.AddXY(3000,60,'',clBlack);



  runfile.free;
 end;


procedure TForm3.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  status:=true;
end;





end.

