program Kompilator;

uses
  Forms,
  MainFrm in 'MainFrm.pas' {MainForm},
  CmplrTypes in 'CmplrTypes.pas',
  CodeFrm in 'CodeFrm.pas' {CodeForm},
  ScopeFrm in 'ScopeFrm.pas' {ScopeForm},
  SymTbl in 'SymTbl.pas' {SymForm};

{$R *.res}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TCodeForm, CodeForm);
  Application.CreateForm(TScopeForm, ScopeForm);
  Application.CreateForm(TSymForm, SymForm);
  Application.Run;
end.
