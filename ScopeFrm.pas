unit ScopeFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls;

type
  TScopeForm = class(TForm)
    Memo: TMemo;
  end;

var
  ScopeForm: TScopeForm;

implementation

{$R *.dfm}

end.
