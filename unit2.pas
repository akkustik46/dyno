unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, synaser;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Cancel: TButton;
    ComboBox1: TComboBox;
    tach_max: TComboBox;
    Label4: TLabel;
    workdir: TEdit;
    Label3: TLabel;
    rollsig: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    ok: TButton;
    SelectDirectoryDialog1: TSelectDirectoryDialog;

    procedure Button1Click(Sender: TObject);
    procedure CancelClick(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure okClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form2: TForm2;
  a,port,SetPort: string;
  Str,Settings,inifile: TStringList;
  i: integer;


implementation
 uses Unit1;
{$R *.lfm}

{ TForm2 }

procedure TForm2.okClick(Sender: TObject);
begin
  Settings := TStringList.Create;
  Settings.Add(Combobox1.Caption);
  Settings.Add(rollsig.Caption);
  Settings.Add(workdir.Caption);
  Settings.Add(tach_max.Caption);
  Settings.SaveToFile('dyno.ini');
  Settings.free;
  Form1.Setup;
  Form2.Close;
  Settings.free;
end;

procedure TForm2.CancelClick(Sender: TObject);
begin
    Form2.Close;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
   workdir.Caption:= SelectDirectoryDialog1.FileName;
end;



procedure TForm2.FormCreate(Sender: TObject);
begin
    inifile:=TStringList.Create;
  inifile.LoadFromFile('dyno.ini');
   Combobox1.Caption:=inifile[0];
   rollsig.Caption:=inifile[1];
   workdir.Caption:=inifile[2];
 a:=GetSerialPortNames;
  Str := TStringList.Create;
  for i:=1 to Length(a) do
      begin
           if a[i]=',' then
            begin
            Str.Add(port);
            port:='';
            end
           else
               begin
          port:=port+a[i];
            end;

      end;
  Str.Add(port);
  Combobox1.Items:=Str;
  Str.Free;
  tach_max.Caption:=inifile[3];
  inifile.Free;
end;

end.

