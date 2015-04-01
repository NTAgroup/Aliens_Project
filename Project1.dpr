program Project1;

uses
  System.StartUpCopy,
  FMX.Forms,
  AdditionalFunctions in 'AdditionalFunctions.pas' {Frame2: TFrame},
  MainUnit in 'MainUnit.pas' {MainForm},
  XSuperJSON in 'x-superobject\XSuperJSON.pas',
  XSuperObject in 'x-superobject\XSuperObject.pas',
  Unit1 in 'Unit1.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
