unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, AdvLed, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls, Menus, ComCtrls, uEGauge, ueled, synaser;

type

  { TForm1 }

  TForm1 = class(TForm)
    graph: TButton;
    Connect: TButton;
    Button2: TButton;
    bikemodel: TEdit;
    cylinders: TComboBox;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    afr_dig: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo2: TMemo;
    bikeconf: TMemo;
    menufile: TMenuItem;
    menuexit: TMenuItem;
    menuopen: TMenuItem;
    menusave: TMenuItem;
    menuclose: TMenuItem;
    OpenDialog1: TOpenDialog;
    Preferences: TMenuItem;
    roll_rpm: TRadioButton;
    roll_kmh: TRadioButton;
    runstart_box: TComboBox;
    Label3: TLabel;
    Label6: TLabel;
    MainMenu1: TMainMenu;
   // PortSet: TMenuItem;
    SaveDialog1: TSaveDialog;
    Settings: TMenuItem;
    StatusBar1: TStatusBar;
    stop: TButton;
    Run: TButton;
    Label1: TLabel;
    Label2: TLabel;
    ratioval: TLabel;
    AFR: TuEGauge;
    uEGauge_eng: TuEGauge;
    uEGauge_roll: TuEGauge;
    WB: TLabel;
    rpmrolvalue: TLabel;
    rpmengvalue: TLabel;
    Memo1: TMemo;
    TBlockSerial1: TBlockSerial;



    procedure AdvLed1Change(Sender: TObject; AState: TLedState);
    procedure graphClick(Sender: TObject);
    procedure menuexitClick(Sender: TObject);
    procedure menuopenClick(Sender: TObject);
    procedure menusaveClick(Sender: TObject);
    procedure PreferencesClick(Sender: TObject);
    procedure ConnectClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure roll_kmhChange(Sender: TObject);
    procedure roll_rpmChange(Sender: TObject);
    procedure RunClick(Sender: TObject);

    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
     procedure stopClick(Sender: TObject);
     procedure Setup;

  private
    { private declarations }
  public
    var
       datetime,loadedfile: string;
       butgraph: boolean;
    { public declarations }
  end;

var
  Form1: TForm1;
  a,t,port,SetPort,mills,workdir, portstring,datetime,loadedfile: string;
  portdata: array of string;
  engrpm_average: array[0..9] of integer;
  b,i,count,x,xold,y,yold,yt,w,c1,c2,c3,oldrolt,oldoldrolt,oldengt,smindx,rpmindx,tmp,rpmtmp,rpmmax,engrpmold,RollTooth,t1,t2,t3: integer;
  Str,inifile,runfile,raw,data: TStringList;
  ratio,o2,alpha,torque,omega,omegaold,rollrpm: real;
  engrpm: Int64;
  status,dynorun,stopbit,butgraph: boolean;
  Hour, Minute, Year, Month, Day,Second,Millisecond: Word;
  sm: TMenuItem;
  const
    moi=4.11384196;
    //  moi=0.001;
implementation
 uses Unit2, Unit3;
{$R *.lfm}

{ TForm1 }


procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.Caption:='DoubleBubbles Dyno';
  StatusBar1.Panels[3].Text:='Selected Port:';
  rpmindx:=0;
  inifile:=TStringList.Create;
  inifile.LoadFromFile('dyno.ini');
  SetPort:=inifile[0];
  RollTooth:=StrToInt(inifile[1]);
  workdir:=inifile[2];
  uEGauge_eng.Max:=StrToInt(inifile[3])/1000;
  uEGauge_eng.LTicks:=StrToInt(inifile[3]) div 1000;
  Opendialog1.InitialDir:=workdir;
  StatusBar1.Panels[4].Text:=SetPort;
  StatusBar1.Panels[5].Text:='Disconnected';
  butgraph:=false;
  Run.Enabled:=false;
  stop.Enabled:=false;


   if SetPort<>'' then
     begin
     Connect.Enabled:=true;
     end;

  inifile.free;

  if roll_kmh.Checked=true then
  begin
      Label10.Caption:='KM/H';
       Label10.Left:=283;
      Label10.Top:=178;
      uEGauge_roll.Max:=300;
      uEGauge_roll.LTicks:=15;
      uEGauge_roll.TicksMargin:=50;
  end
  else
  begin
     Label10.Caption:='x100'+#13+'RPM';
     uEGauge_roll.Max:=60;
      Label10.Left:=287;
      Label10.Top:=168;
      uEGauge_roll.LTicks:=12;
      uEGauge_roll.TicksMargin:=53;
  end;
end;

procedure TForm1.Setup;
begin
  inifile:=TStringList.Create;
  inifile.LoadFromFile('dyno.ini');
  SetPort:=inifile[0];
  RollTooth:=StrToInt(inifile[1]);
  StatusBar1.Panels[4].Text:=SetPort;
  uEGauge_eng.Max:=StrToInt(inifile[3])/1000;
  uEGauge_eng.LTicks:=StrToInt(inifile[3]) div 1000;
end;

procedure TForm1.PreferencesClick(Sender: TObject);
begin
  Form2.ShowModal;
  Application.CreateForm(TForm2, Form2);
end;

procedure TForm1.menuexitClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.graphClick(Sender: TObject);
begin
  butgraph:=true;
  Form3.ShowModal;
  Application.CreateForm(TForm3, Form3);

end;

procedure TForm1.AdvLed1Change(Sender: TObject; AState: TLedState);
begin

end;

procedure TForm1.menuopenClick(Sender: TObject);
begin
  If Opendialog1.Execute then
   loadedfile:=OpenDialog1.FileName;
  StatusBar1.Panels[0].Text:=loadedfile;
end;

procedure TForm1.menusaveClick(Sender: TObject);
begin
  datetime:=FormatDateTime('yyyy-mm-dd_hhnnss', Now);
  SaveDialog1.Filename:= bikemodel.caption+'_'+datetime+'.run';
  if SaveDialog1.Execute then
    Memo1.Lines.SaveToFile( SaveDialog1.Filename );

end;

procedure TForm1.stopClick(Sender: TObject);
begin
  status:=false;
  butgraph:=false;
  stop.Enabled:=false;
  Run.Enabled:=true;
  dynorun:=false;
  stopbit:=false;
  runfile:=TStringList.Create;
  ForceDirectories(workdir+'\'+bikemodel.caption+'\');
  datetime:=FormatDateTime('yyyy-mm-dd_hhnnss', Now);
  runfile.Add(bikemodel.caption);
  runfile.Add('---------');
  runfile.Add(runstart_box.Caption);
  runfile.Add('---------');
  runfile.Add(cylinders.Caption);
  runfile.Add('---------');
  runfile.Add(bikeconf.Lines.Text);
  runfile.Add('---------');
  runfile.AddStrings(raw);
  runfile.SaveToFile(workdir+'\'+bikemodel.caption+'\'+bikemodel.caption+'_'+datetime+'.run');
  loadedfile:=workdir+'\'+bikemodel.caption+'\'+bikemodel.caption+'_'+datetime+'.run';
  StatusBar1.Panels[0].Text:=loadedfile;
  Label3.Caption:=IntToStr(Memo1.Lines.Count);
  SaveDialog1.InitialDir:=workdir+'\'+bikemodel.caption+'\';
  runfile.free;
  raw.Free;
  Form3.ShowModal;
  Application.CreateForm(TForm3, Form3);
end;


procedure TForm1.ConnectClick(Sender: TObject);
begin
 GetSerialPortNames;
 Connect.Enabled:=false;
 Run.Enabled:=true;
 Run.Default:=true;
 TBlockSerial1:=TBlockSerial.Create;
 raw:=TStringList.Create;
 StatusBar1.Panels[5].Text:='Connected';
  TBlockSerial1.Connect(SetPort);
  TBlockSerial1.Config(9600,8,'N',0,false,false);
  dynorun:=false;
  status:=true;
  stopbit:=true;
  Memo1.Clear;
   SetLength(portdata, 10);
  data:=Tstringlist.Create;
  data.Delimiter:=',';
  t1:=0;
  t2:=0;
  t3:=0;
  omegaold:=0;
  xold:=0;
 while status=true do
 begin
      count:=0;
      portstring:=TBlockSerial1.Recvstring(100);
      data.DelimitedText:=portstring;
      mills:='';
      for i:=1 to Length(portstring) do
      begin
           if portstring[i]=',' then
            begin
            //Str.Add(PortSet);
            portdata[count]:=mills;
            count:=count+1;
            mills:='';
            end
           else
               begin
                mills:=mills+portstring[i];

            end;
         portdata[count]:=mills;
      end;

      if dynorun=true then
      begin
      Memo1.Append(portstring);
      raw.Add(portstring);

      end;
      if data.Count=11 then
          begin
              t3:=StrToInt(data[2]);
              y:=StrToInt(data[4]);
              w:=StrToInt(data[10]);
     // Val(portdata[2], t3, c1);
     // Val(portdata[1], x, c1);
     // Val(portdata[4], y, c2);
     // Val(portdata[3], yt, c2);
     // Val(portdata[10], w, c3);
         end;
       //Memo2.Append(IntToStr(data.Count));
           if t3<>0 then
                begin
             //   t3:=StrToInt(data[2]);
                rollrpm:=(1/(t3/1000000))*(60/RollTooth);
                omega:=((2*pi)/RollTooth)/(t3/1000000);
                alpha:=((omega-omegaold)/(t3/1000000));
                  omegaold:=omega;
                  t1:=t2;
                  t2:=t3;
                  xold:=x;
                end;

      if y<>0 then
         begin
        // if(y-oldengt)=0 then
         //   begin

            engrpmold:=engrpm;
         engrpm:=(60000000 div (y)) div StrToInt(cylinders.Caption) ;
         oldengt:=y;

            end
         else
         begin
            engrpm:=0;
            oldengt:=y;
          end;
        // end
        // else
        // begin
        // engrpm:=0;
        // end;

      rpmrolvalue.Caption:=FloatToStr(rollrpm);
      rpmengvalue.Caption:=IntToStr(engrpm);
      torque:=alpha*moi;
      Label1.Caption:='Current Torque:'+FloatToStrF(torque,ffGeneral,5,5);
      Label9.Caption:=FloatToStr(alpha);
      Label3.Caption:=FloatToStr(omega);
      //Average Engine RPM
      {
      engrpm_average[rpmindx]:=engrpm;
      rpmindx:=rpmindx+1;
         if rpmindx>9 then
            begin
            rpmindx:=0;
            end;
         rpmtmp:=0;
         for tmp:=0 to 9 do
                  rpmtmp:=engrpm_average[tmp]+rpmtmp;
       //Label3.Caption:=IntToStr(rpmtmp div 10);
          Label3.Caption:=IntToStr(rpmmax);
       }
       //END Average Engine RPM

      uEGauge_eng.Position:=engrpm/100;
      if roll_kmh.Checked=true then
        begin
          uEGauge_roll.Position:=rollrpm*(pi*0.325)*60/1000;
        end
      else
      begin
      uEGauge_roll.Position:=rollrpm/100;
      end;
      o2:=(5/1024)*w;

      AFR.Position:=7.35+((o2/5)*((22.39-7.35)/1));
      afr_dig.Caption:=FloatTostrF(AFR.Position,ffGeneral,4,2);
        if engrpm>rpmmax then
           begin
               rpmmax:=engrpm;
           end;
        // end;

      //Dynorun mode switch
         if stopbit=true then
            begin
         if dynorun=false then
            begin
                 if runstart_box.Caption='OFF' then
                   begin

                   end
                 else
                 begin
                 if engrpm>=StrToInt(runstart_box.Caption) then
                    begin
                         //dynorun:=true;
                    Run.Click;
                    end;

                 end;
            end;
         //if (rpmtmp div 10)<rpmmax then
         //   begin
         //        dynorun:=false;
         //   end;

           end;
        //End Dynorun mode switch

         if rollrpm<>0 then
                        begin
                             ratio:= engrpm/rollrpm;
                             ratioval.Caption:=FloatToStr(ratio);
                        end
            else
                begin
                     ratio:=0;
                     ratioval.Caption:=FloatToStr(ratio);
                end;

      Application.ProcessMessages();

 end;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 status:=false;
 Connect.Enabled:=true;
 Run.Enabled:=false;
 stop.Enabled:=false;
   if StatusBar1.Panels[5].Text<>'' then
 // if SetPort<>'' then
    begin
 TBlockSerial1.CloseSocket;
 StatusBar1.Panels[5].Text:='Disconnected';
    end;
end;

procedure TForm1.roll_kmhChange(Sender: TObject);
begin
   if roll_kmh.Checked=true then
      begin
     Label10.Caption:='KM/H';
     Label10.Left:=283;
      Label10.Top:=178;
      uEGauge_roll.Max:=300;
      uEGauge_roll.LTicks:=15;
      uEGauge_roll.TicksMargin:=50;
     end;
end;

procedure TForm1.roll_rpmChange(Sender: TObject);
begin
   if roll_rpm.Checked=true then
   begin
     Label10.Caption:='x100'+#13+'RPM';
     Label10.Left:=287;
      Label10.Top:=168;
      uEGauge_roll.Max:=60;
      uEGauge_roll.LTicks:=12;
      uEGauge_roll.TicksMargin:=53;
   end;
end;

procedure TForm1.RunClick(Sender: TObject);
begin
     dynorun:=true;
     Memo1.Clear;
     Run.Enabled:=false;
     stop.Enabled:=true;
     stop.Cancel:=true;;
     raw:=TStringList.Create;

end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

 status:=false;
// if SetPort<>'' then
if StatusBar1.Panels[5].Text='Connected' then
begin
  TBlockSerial1.CloseSocket;

   end;

end;

end.

