unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, ComCtrls, ToolWin, Menus, ImgList,
  CmplrTypes, ActnList;

type
  TMainForm = class(TForm)
    ActionList: TActionList;
    acExit: TAction;
    ToolBar: TToolBar;
    ToolButton1: TToolButton;
    MainMenu: TMainMenu;
    mmiFile: TMenuItem;
    mmiExit: TMenuItem;
    Memo: TMemo;
    Splitter: TSplitter;
    ListBox: TListBox;
    acCompile: TAction;
    mmiProject: TMenuItem;
    Compile1: TMenuItem;
    acOpen: TAction;
    acNew: TAction;
    New1: TMenuItem;
    Open1: TMenuItem;
    N1: TMenuItem;
    btnNew: TToolButton;
    btnOpen: TToolButton;
    ToolButton4: TToolButton;
    btnCompile: TToolButton;
    ImageList: TImageList;
    mmiView: TMenuItem;
    mmiCode: TMenuItem;
    mmiScopes: TMenuItem;
    mmiSymboltable: TMenuItem;
    btnSave: TToolButton;
    acSave: TAction;
    Save1: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    procedure acExitExecute(Sender: TObject);
    procedure acCompileExecute(Sender: TObject);
    procedure acOpenExecute(Sender: TObject);
    procedure acNewExecute(Sender: TObject);
    procedure mmiCodeClick(Sender: TObject);
    procedure mmiScopesClick(Sender: TObject);
    procedure mmiSymboltableClick(Sender: TObject);
    procedure acSaveExecute(Sender: TObject);
  end;

const
  { Для полей Oprnd1, Oprnd2, Res по умолчанию }
  Empty: TExprInfo = (Mode: M_VALUE;
                      Value: 0;
                      ExprType: 0);

var
  { Таблица объектов компиляции и их таблицы доп. инфо }
  Objects: array of TNamedObject;
  Variables: array of TVariable;
  Constants: array of TConstant;
  Types: array of TType;
  ScalarTypes: array of TScalarType;
  OrdinalTypes: array of TOrdinalType;
  StaticArray: array of TArray;
  Procedures: array of TProcedure;
  Functions: array of TFunction;
  NamedTypes: array of string;
  { Массив с (изображениями) операциями промежуточного кода }
  OPIMG: array [TOperation] of string =
    ('ADD','SUB','MUL','DIV','PUSH','POP','MOV','STORE','LOAD',
     'JMP','CJMP','CALL','RET','GT','LT','EQ','NE','HLT');
  { Массив с программой на промежуточном коде }
  Code: array of TQuad;

  IDLIST: array of integer;
  PARAMLIST: array of TParam;
  PARAMGROUPLIST: array of integer;
  TARGETTYPE, TARGETVALUE, PARAMGROUPLISTTYPE, PROCID: integer;
  TARGETMODE: TExprMode;
  RegUse: array [0..31] of boolean;

  { Указатели на сист., глоб., тек. области видимости }
  SystemScope, GlobalScope, TopScope: PScope;
  { Указатели на константы и типы языка разбора }
  BOOLEAN_TYPE_OBJ, BOOLEAN_TYPE, FALSE_CONST, FALSE_CONST_OBJ: integer;
  TRUE_CONST_OBJ, TRUE_CONST, INTEGER_TYPE, INTEGER_TYPE_OBJ: integer;
  NEW_VAR, NEW_VAR_OBJ, NEW_PROC, NEW_FUNCT, NEW_PROC_OBJ, NEW_FUNCT_OBJ,
  ID_RESULT: integer;
  
type TLexeme = (
     LEX_CONST,    LEX_PROGR,   LEX_FUNCT,
     LEX_TYPE,
     LEX_BEGIN,    LEX_END,     LEX_IF,
     LEX_THEN,     LEX_ELSE,    LEX_VAR,
     LEX_PROC,     LEX_DO,      LEX_WHILE,
     LEX_ARRAY,    LEX_OF,      LEX_ID,
     LEX_STR,      LEX_INT,     LEX_PLUS,
     LEX_COLON,    LEX_SEMICOL, LEX_ASSIGN,
     LEX_DOT,      LEX_LPAREN,  LEX_RPAREN,
     LEX_MINUS,    LEX_LKPAREN, LEX_RKPAREN,
     LEX_TWODOT,   LEX_HEX,     LEX_KOV,
     LEX_EQUAL,    LEX_BIG,     LEX_SMALL,
     LEX_NOTEQUAL, LEX_COL,     LEX_UMNOZ,
     LEX_DELEN,    LEX_EOF,     LEX_UNNOUN);

const
  IMG: array [TLexeme] of string =
    ('const',     'program', 'function',
     'type',
     'begin',     'end',     'if',
     'then',      'else',    'var',
     'procedure', 'do',      'while',
     'array',     'of',      '<ID>',
     '<STR>',     '<INT>',   '+',
     ':',         ';',       ':=',
     '.',         '(',       ')',
     '-',         '[',       ']',
     '..',        '$',       '"',
     '=',         '>',       '<',
     '<>',        ',',       '*',
     '/',         'eof',     'illegal symbol');

var
  MainForm: TMainForm;
  Lexeme: TLexeme;
  LexValue, StartPos, ParsePos, Line, Column, ErrorPos, tmpline, tmpcol: integer;
  Identifiers: array of string;
  Source: string;
  CurCh, TmpCh: char;
  IsError, IsGlobal: boolean;

implementation

uses
  CodeFrm, ScopeFrm, SymTbl;

function PutQuad(Op: TOperation; a1, a2, a3: TExprInfo): integer;
var
  L: integer;
begin
  L:=Length(code);
  SetLength(code,L+1);
  code[L].op:=op;
  code[L].Oprnd1:=a1;
  code[L].Oprnd2:=a2;
  code[L].Res:=a3;
  Result:=L;
end;

procedure FixQuad(nq, na, nn: integer);
var
  i:integer;
begin
  i:=0;
  while (i <= Length(code)) and (i <> nq) do
    Inc(i);
  if i = nq then
  begin
    case na of
      1: code[i].Oprnd1.value:=nn;
      2: code[i].Oprnd2.value:=nn;
      3: code[i].Res.value:=nn;
    end;
  end;
end;

function LexToOp(oplex: TLexeme): TOperation;
begin
  Result:=OP_ADD;
  case oplex of
    LEX_PLUS:  Result:=OP_ADD;
    LEX_MINUS: Result:=OP_SUB;
    LEX_UMNOZ: Result:=OP_MUL;
    LEX_DELEN: Result:=OP_DIV;
  end;
end;

procedure ErrorAt(Msg: string; L,C: integer);
begin
  if ErrorPos < StartPos then
  begin
    if C = 0 then
      C:=1;
    MainForm.ListBox.Items.Add('Error'+ '('+ IntToStr(L) + ',' + IntToStr(C) + '): ' +  Msg);
    ErrorPos:=StartPos;
    IsError:=True;
  end;
end;

procedure Error_A(Msg: string); 
begin
  ErrorAt(Msg,Line,Column-(ParsePos-StartPos));
end;

function NewType(mode: TTypeMode; index: integer): integer;
begin
  SetLength(Types,Length(Types)+1);
  Types[Length(Types)-1].mode:=mode;
  Types[Length(Types)-1].index:=index;
  Result:=Length(Types)-1;
end;

procedure NewNamedType(name: string);
begin
  SetLength(NamedTypes,Length(NamedTypes)+1);
  NamedTypes[Length(NamedTypes)-1]:=name;
end;

function NewOrdinal(Low, High: integer): integer;
begin
  SetLength(OrdinalTypes,Length(OrdinalTypes) + 1);
  OrdinalTypes[Length(OrdinalTypes)-1].low:=Low;
  OrdinalTypes[Length(OrdinalTypes)-1].high:=High;
  Result:=Length(OrdinalTypes) - 1;
end;

function NewScalar(mode: TScalarMode; size, index: integer): integer;
begin
  SetLength(ScalarTypes,Length(ScalarTypes) + 1);
  ScalarTypes[Length(ScalarTypes) - 1].mode:=mode;
  ScalarTypes[Length(ScalarTypes) - 1].index:=index;
  ScalarTypes[Length(ScalarTypes) - 1].size:=size;
  Result:=Length(ScalarTypes) - 1;
end;

function NewObject(mode: TObjectMode; index: integer): integer;
begin
  SetLength(Objects,Length(Objects) + 1);
  Objects[Length(Objects) - 1].mode:=mode;
  objects[Length(Objects) - 1].index:=index;
  Result:=Length(Objects) - 1;
end;

function NewID(name: string): integer;
begin
  SetLength(Identifiers,Length(Identifiers) + 1);
  Identifiers[Length(Identifiers) - 1]:=name;
  Result:=Length(Identifiers) - 1;
end;

function NewConst(typeindex, valueindex: integer): integer;
begin
  SetLength(Constants,Length(Constants)+1);
  Constants[Length(Constants) - 1].typeindex:=typeindex;
  Constants[Length(Constants) - 1].valueindex:=valueindex;
  Result:=Length(Constants) - 1;
end;

function NewVar(mode:TVarMode;offset:integer;typeindex:integer):integer;
begin
  SetLength(Variables,Length(Variables) + 1);
  Variables[Length(Variables) - 1].mode:=mode;
  Variables[Length(Variables) - 1].offset:=offset;
  Variables[Length(Variables) - 1].typeindex:=typeindex;
  Result:=Length(Variables) - 1;
end;

function NewArray(basetypeindex:integer;indexordinaltypeindex:integer):integer;
begin
  SetLength(StaticArray,Length(StaticArray) + 1);
  StaticArray[Length(StaticArray) - 1].BaseTypePtr:=basetypeindex;
  StaticArray[Length(StaticArray) - 1].IndexTypePtr:=indexordinaltypeindex;
  Result:=Length(StaticArray) - 1;
end;

function NewProcedure(params: array of TParam; entrypoint: integer):integer;
var
  i: integer;
begin
  SetLength(Procedures,Length(Procedures) + 1);
  for i:=0 to High(params) do
  begin
    SetLength(Procedures[Length(Procedures) - 1].params,i + 1);
    Procedures[Length(Procedures) - 1].params[i]:=params[i];
  end;
  Procedures[Length(Procedures) - 1].entrypoint:=entrypoint;
  Result:=Length(Procedures) - 1;
end;

function NewFunction(params: array of TParam; entrypoint: integer; tptr: integer): integer;
var
  i: integer;
begin
  SetLength(Functions,Length(Functions) + 1);
  for i:=0 to High(params) do
  begin
    SetLength(Functions[Length(Functions) - 1].params,i + 1);
    Functions[Length(Functions) - 1].params[i]:=params[i];
  end;
  Functions[Length(Functions) - 1].entrypoint:=entrypoint;
  Functions[Length(Functions) - 1].TypePtr:=tptr;
  Result:=Length(Functions) - 1;
end;

function SizeOfType(index:integer):integer;
begin
  Result:=0;
  case Types[index].mode of
    M_SCALAR: Result:=ScalarTypes[Types[index].index].size;
    M_ARRAY:  Result:=(OrdinalTypes[StaticArray[Types[index].index].IndexTypePtr].high-
                       OrdinalTypes[StaticArray[Types[index].index].IndexTypePtr].low+1)*
                      (SizeOfType(StaticArray[Types[index].index].BaseTypePtr));
  end;
end;

procedure OpenScope(const s: string);
var
  tmp:PScope;
begin
  new(tmp);
  SetLength(tmp.Objects,0);
  tmp.allocated:=0;
  tmp.parent:=TopScope;
  TopScope:=tmp;
  ScopeForm.Memo.Lines.Add('<<< Scope ''' + s + ''' has been opened.');
end;

procedure CloseScope;
var
  tmp: PScope;
begin
  tmp:=TopScope^.parent;
  SetLength(TopScope.Objects,0);
  dispose(TopScope);
  topScope:=tmp;
  ScopeForm.Memo.Lines.Add('>>> Scope has been closed. ');
end;

procedure EnterObject(id, index: integer);
var
  i:integer;
  L:integer;
begin
  L:=Length(TopScope.Objects);
  SetLength(TopScope.Objects,L+1);
  i:=0;
  TopScope.Objects[L].SymPtr:=id;
  while TopScope.Objects[i].SymPtr <> id do
    Inc(i);
  if i < L then
  begin
    SetLength(TopScope.Objects,L);
    Error_A('Identifier redeclared: ' + Identifiers[id]);
  end
  else begin
    TopScope.Objects[L].ObjPtr:=index;
    ScopeForm.Memo.Lines.Add('   Object ''' + Identifiers[id] + ''' inserted');
  end;  
end;

function FindObject(id: integer): integer;
var
  i: integer;
  TmpScope: PScope;
begin
  Result:=0;
  TmpScope:=TopScope;
  repeat
    i:=0;
    while (i < Length(TmpScope.Objects)) and (TmpScope.Objects[i].SymPtr <> id) do
      Inc(i);
    if i = Length(TmpScope.Objects) then
      if nil = TmpScope.parent then
        break
      else
        TmpScope:=TmpScope.parent
    else
    begin
      Result:=TmpScope.Objects[i].ObjPtr;
      exit;
    end;
  until false;
  Error_A('Undeclared identifier: ' + '"' + Identifiers[id] + '"');
end;

procedure InitScan;
var
  i:integer;
begin
  Line:=1;
  Column:=0;
  Source:=MainForm.Memo.Text + #0;
  CurCh:=Source[1];
  ParsePos:=2;
  ErrorPos:=-1;
  StartPos:=1;
  IsError:=false;
  IsGlobal:=true;
  for i:=Low(RegUse) to High(RegUse) do
    RegUse[i]:=false;
end;

procedure Scan;
  procedure Error_Here(Msg: string); 
  begin
    ErrorAt(Msg,Line,Column);
  end;
  
  procedure NextChar;
  begin
    CurCh:=Source[ParsePos];
    Inc(ParsePos);
    if CurCh = #10 then
    begin
      Inc(Line);
      Column:=0;
    end
    else
      Inc(Column);
  end;

  procedure GetID;
  var
    Buffer: string; 
    i: TLexeme;
    j: integer;
  begin
    Buffer:='';
    repeat
      Buffer:=Buffer + CurCh;
      NextChar;
    until not (CurCh in ['A'..'Z','a'..'z','_','0'..'9']);

    i:=LEX_CONST;
    Buffer:=LowerCase(Buffer);
    while (i < LEX_ID) and (IMG[i] <> Buffer) do
      Inc(i);
    Lexeme:=i;
    if Lexeme = LEX_ID then
    begin
      SetLength(Identifiers,Length(Identifiers) + 1);
      Identifiers[Length(Identifiers) - 1]:=Buffer;
      j:=0;
      while Identifiers[j] <> Buffer do
        Inc(j);
      if j < Length(Identifiers) - 1 then
        SetLength(Identifiers,Length(Identifiers) - 1);
      LexValue:=j;
    end;
  end;

  procedure GetNUM;
  var
    Buffer: string;
  begin
    Buffer:='';
    repeat
      Buffer:=Buffer+CurCh;
      NextChar;
    until not(CurCh in ['0'..'9']);
    Lexeme:=LEX_INT;
    LexValue:=StrToInt(Buffer);
  end;

  procedure GetHexNum;
  var
    Buffer: string;
  const
    HexDigits = '0123456789ABCDEF';
  begin
    Buffer:='';
    NextChar;
    LexValue := 0;
    while UpCase(CurCh) in ['0'..'9','A','B','C','D','E','F'] do
    begin
      Buffer:=Buffer+CurCh;
      LexValue := 16 * LexValue + Pos(UpCase(CurCh),HexDigits) - 1;
      NextChar;
    end;
    Lexeme:=LEX_INT;
    if Length(Buffer)=0 then
      Lexeme:=LEX_UNNOUN;
  end;
begin
  LexValue := -1;
  while CurCh in [#1..#32] do
    NextChar;
  StartPos:=ParsePos;

  case CurCh of
    'A'..'Z','a'..'z','_': GetID;
    '0'..'9': GetNUM;
    ';': begin Lexeme:=LEX_SEMICOL; NextChar end;
    ',': begin Lexeme:=LEX_COL; NextChar end;
    '=': begin Lexeme:=LEX_EQUAL; NextChar end;
    '>': begin Lexeme:=LEX_BIG; NextChar end;
    '*': begin Lexeme:=LEX_UMNOZ; NextChar end;
    '/': begin Lexeme:=LEX_DELEN; NextChar end;
    '+': begin Lexeme:=LEX_PLUS; NextChar end;
    '-': begin Lexeme:=LEX_MINUS; NextChar end;
    '[': begin Lexeme:=LEX_LKPAREN; NextChar end;
    ']': begin Lexeme:=LEX_RKPAREN; NextChar end;
    '(': begin Lexeme:=LEX_LPAREN; NextChar end;
    ')': begin Lexeme:=LEX_RPAREN; NextChar end;
    '.': begin
           NextChar;
           if CurCh='.' then
           begin
             Lexeme:=LEX_TWODOT;
             NextChar;
           end else
             Lexeme:=LEX_DOT;
         end;
    '$': GetHexNum;
    ':': begin
           NextChar;
           if CurCh='=' then
           begin
             Lexeme:=LEX_ASSIGN;
             NextChar;
           end else
             Lexeme:=LEX_COLON;
         end;
    '<': begin
           NextChar;
           if CurCh='>' then
           begin
             Lexeme:=LEX_NOTEQUAL;
             NextChar;
           end else
             Lexeme:=LEX_SMALL;
         end;
    #0: Lexeme:=LEX_EOF;
    else begin
      Lexeme:=LEX_UNNOUN;
      Error_Here('Illegal character');
    end;
  NextChar;
  end;
end;

function GetExpr:TExprInfo; forward;
procedure GetActualParam; forward;
procedure GetActualFunParam; forward;
procedure GetStatement; forward;
procedure GetBlock; forward;
function GetType:integer; forward;
procedure GetDeclaration; forward;

function GetFreeRegister:integer;
var
  i:integer;
begin
  Result:=0;
  i:=0;
  while (i <= Length(RegUse) - 1) and (RegUse[i] <> false) do
    Inc(i);
  if RegUse[i] = false then
  begin
    RegUse[i]:=true;
    Result:=i;
  end
  else
    if i > Length(RegUse)-1 then
      Error_A('Your Expression is too different');
end;

procedure ReleaseReg(R: integer);
begin
  RegUse[R]:=false;
end;

function InferType(oplex: TLexeme; a, b: integer): integer;
begin
  Result:=0;
  if a <> b then
    Error_A('Incompatible types: ' + '"' + NamedTypes[a] + '"' + ' and ' + '"' +
      NamedTypes[b] + '"');
  case oplex of
    LEX_SMALL,LEX_BIG,LEX_NOTEQUAL,LEX_EQUAL: Result:=BOOLEAN_TYPE;
    LEX_PLUS,LEX_MINUS: Result:=INTEGER_TYPE;
    LEX_UMNOZ,LEX_DELEN: Result:=INTEGER_TYPE;
  end;
end;

procedure Eat(L: TLexeme);
begin
  if  Lexeme <> L then
    Error_A('"' + IMG[L] + '"' + ' expected, but ' + '"' + IMG[Lexeme] + '"' +
      ' found.');
  Scan;
end;

function GetTarget: TExprInfo;
var
  ID,Obj: integer;
begin
  if Lexeme = LEX_ID then
  begin
    ID:=LexValue;
    Eat(LEX_ID);
    Obj:=FindObject(ID);
    if Objects[Obj].mode <> M_VAR then
      Error_A('Identifier ' + '"' + IMG[LEX_ID] + '"' + ' is not a variable.');
    Result.mode:=M_MEMORY;
    Result.value:=SizeOfType(Objects[Obj].index);
    Result.exprtype:=Objects[Obj].index;
  end;
end;

function GetFactor: TExprInfo;
var
  ID,Obj:integer;
  a,d1,d2,d3,d4: TExprInfo;
begin
  case Lexeme of 
    LEX_ID:
      begin
        ID:=LexValue;
        Eat(LEX_ID);
        Obj:=FindObject(ID);
        if Objects[Obj].mode <> M_VAR then
        begin
          if Objects[Obj].Mode = M_FUNCT then
          begin
            Result.mode:=M_VALUE;
            Result.value:=Functions[Objects[Obj].index].entrypoint;
            Result.exprtype:=Functions[Objects[Obj].index].TypePtr;
            PutQuad(OP_CALL,Result,Empty,Empty);
            Exit;
          end;
          
          if Objects[Obj].mode <> M_CONST then
          begin
            Error_A('Identifier '+'"'+IMG[LEX_ID]+'"'+' is not a constant or variable');
            Result.mode:=M_MEMORY;
            Result.value:=0;
            Result.exprtype:=0;
          end
          else begin
            Result.mode:=M_VALUE;
            Result.value:=Constants[Objects[Obj].index].valueindex;
            Result.exprtype:=Constants[Objects[Obj].index].typeindex;
          end;
        end
        else begin
          Result.mode:=M_MEMORY;
          if Variables[Objects[Obj].index].mode = M_GLOBAL then
            Result.value:=Variables[Objects[Obj].index].offset
          else
            Result.value:=-Variables[Objects[Obj].index].offset;
            Result.exprtype:=Variables[Objects[Obj].index].typeindex;
          end;
          case Lexeme of
            LEX_LKPAREN:
              begin
                Eat(LEX_LKPAREN);
                a:=GetExpr;
                Eat(LEX_RKPAREN);
                if a.exprtype<>INTEGER_TYPE then
                  Error_A('Index of array must be "integer"')
                else begin
                  case a.mode of
                    M_VALUE:
                       begin
                         if Types[Variables[Objects[Obj].index].typeindex].mode=M_ARRAY then
                         begin
                           if (a.value<OrdinalTypes[StaticArray[Types[Variables[Objects[Obj].index].typeindex].index].IndexTypePtr].low)or
                             (a.value>OrdinalTypes[StaticArray[Types[Variables[Objects[Obj].index].typeindex].index].IndexTypePtr].high) then
                             Error_A('Index of array is out of bounds');
                           Result.exprtype:=StaticArray[Types[Variables[Objects[Obj].index].typeindex].index].BaseTypePtr;
                           Result.mode:=M_MEMORY;
                           Result.value:=Variables[Objects[Obj].index].offset+a.value*SizeOfType(StaticArray[Types[Variables[Objects[Obj].index].typeindex].index].BaseTypePtr);
                         end;
                       end;
                     M_MEMORY,M_REGISTER:
                        begin
                          d1.mode:=M_REGISTER;
                          d1.exprtype:=0;
                          d1.value:=GetFreeRegister;
                          d2.mode:=M_VALUE;
                          d2.exprtype:=0;
                          d2.value:=SizeOfType(StaticArray[Types[Variables[Objects[Obj].index].typeindex].index].BaseTypePtr);
                          PutQuad(OP_MOV,d1,d2,Empty);
                          d3.mode:=M_REGISTER;
                          d3.value:=GetFreeRegister;
                          d3.exprtype:=0;
                          PutQuad(OP_MUL,d1,a,d3);
                          PutQuad(OP_ADD,d3,a,d1);
                          d4.mode:=M_REGISTER;
                          d4.value:=GetfreeRegister;
                          d4.exprtype:=StaticArray[Types[Variables[Objects[Obj].index].typeindex].index].BaseTypePtr;
                          PutQuad(OP_LOAD,d4,d1,Empty);
                          Result.mode:=M_REGISTER;
                          Result.value:=d4.value;
                          Result.exprtype:=d4.exprtype;
                          ReleaseReg(d1.value);
                          ReleaseReg(d3.value);
                          ReleaseReg(d4.value);
                          if a.mode=M_REGISTER then ReleaseReg(a.value);
                        end
                        else
                          Error_A('Variable '+'"'+Identifiers[ID]+'"'+' is not array');
                      end;
                    end;
                  end;
                end;
              end;

    LEX_LPAREN:
      begin
        Eat(LEX_LPAREN);
        Result:=GetExpr;
        Eat(LEX_RPAREN);
      end;

    LEX_STR: Eat(LEX_STR);
    else begin
        Result.mode:=M_VALUE;
        Result.exprtype:=INTEGER_TYPE;
        Result.value:=LexValue;
        Eat(LEX_INT);
      end;
  end;
end;

function GetTerm: TExprInfo;
var
  a,b,c:TExprInfo;
  oplex:TLexeme;
begin
  a:=GetFactor;
  while (Lexeme = LEX_UMNOZ) or (Lexeme = LEX_DELEN) do
  begin
    oplex:=Lexeme;
    Eat(oplex);
    b:=GetFactor;
    c.exprtype:=InferType(oplex,a.exprtype,b.exprtype);
    c.mode:=M_REGISTER;
    c.value:=GetFreeRegister;
    PutQuad(LexToOp(oplex),a,b,c);
    if a.mode=M_REGISTER then ReleaseReg(a.value);
    if b.mode=M_REGISTER then ReleaseReg(b.value);
    a:=c;
  end;
  Result:=a;
end;

function GetSimpleExpr: TExprInfo;
var
  a,b,c:TExprInfo;
  oplex:TLexeme;
begin
  a:=GetTerm;
  while (Lexeme = LEX_PLUS) or (Lexeme = LEX_MINUS) do
  begin
    oplex:=Lexeme;
    Eat(oplex);
    b:=GetTerm;
    c.exprtype:=InferType(oplex,a.exprtype,b.exprtype);
    c.mode:=M_REGISTER;
    c.value:=GetFreeRegister;
    PutQuad(LexToOp(oplex),a,b,c);
    if a.mode = M_REGISTER then ReleaseReg(a.value);
    if b.mode = M_REGISTER then ReleaseReg(b.value);
    a:=c;
  end;
  Result:=a;
end;

function GetExpr: TExprInfo;
var
  a,b,c:TExprInfo;
  oplex:TLexeme;
begin
  a:=GetSimpleExpr;
  oplex:=Lexeme;
  if (oplex = LEX_SMALL) or (oplex = LEX_BIG) or (oplex = LEX_NOTEQUAL) or (oplex=LEX_EQUAL) then
  begin
    Eat(oplex);
    b:=GetSimpleExpr;

    c.mode:=M_REGISTER;
    c.value:=GetFreeRegister;
    c.exprtype:=InferType(oplex,a.exprtype,b.exprtype);

    case oplex of
      LEX_SMALL: PutQuad(OP_LT,a,b,c);
      LEX_BIG:   PutQuad(OP_GT,a,b,c);
      LEX_EQUAL: PutQuad(OP_EQ,a,b,c);
      LEX_NOTEQUAL: PutQuad(OP_NE,a,b,c);
    end;

    if a.mode=M_REGISTER then ReleaseReg(a.value);
    if b.mode=M_REGISTER then ReleaseReg(b.value);

    Result.exprtype:=c.exprtype;
    Result.mode:=c.mode;
    Result.value:=c.value;
  end
  else
    Result:=a;
end;

function GetName: integer;
var
  ID:integer;
begin
  ID:=LexValue;
  Eat(LEX_ID);
  Result:=ID;
end;

procedure GetActualParam;
var
  a: TExprInfo;
  i: integer;
begin
  i:=0;
  if Length(Procedures[Objects[PROCID].index].params) <> i then
  begin
    i:=1;
    a:=GetExpr;
    if Length(Procedures[Objects[PROCID].index].params) >= i then
    begin
      if a.exprtype <> Procedures[Objects[PROCID].index].params[i-1].TypePtr then
       Error_A('Can not compare types: ' + '"' + NamedTypes[a.exprtype] + '"' + ' with ' +
         '"' + NamedTypes[Procedures[Objects[PROCID].index].params[0].typeptr] + '"');
      PutQuad(OP_PUSH,a,Empty,Empty);
    end
    else
      Error_A('Too many params');
    while Lexeme = LEX_COL do
    begin
      Eat(LEX_COL);
      i:=i+1;
      a:=GetExpr;
      if Length(Procedures[Objects[PROCID].index].params)>=i then
      begin
        if a.exprtype<>Procedures[Objects[PROCID].index].params[i-1].TypePtr then
          Error_A('Can not compare types: ' + '"' + NamedTypes[a.exprtype] + '"' + ' with ' +
            '"' + NamedTypes[Procedures[Objects[PROCID].index].params[i-1].typeptr] + '"');
        PutQuad(OP_PUSH,a,Empty,Empty);
      end
      else
        Error_A('Too many params');
    end;
    if Length(Procedures[Objects[PROCID].index].params) <> i then
      Error_A('Too few params');
  end
  else
    if Lexeme<>LEX_SEMICOL then
      Error_A('Too many params');
end;

procedure GetActualFunParam;
var
  a: TExprInfo;
  i: integer;
begin
  i:=0;
  if Length(Functions[Objects[PROCID].index].params) <> i then
  begin
    i:=1;
    a:=GetExpr;
    if Length(Functions[Objects[PROCID].index].params) >= i then
    begin
      if a.exprtype <> Functions[Objects[PROCID].index].params[i-1].TypePtr then
       Error_A('Can not compare types: ' + '"' + NamedTypes[a.exprtype] + '"' + ' with ' +
         '"' + NamedTypes[Functions[Objects[PROCID].index].params[0].typeptr] + '"');
      PutQuad(OP_PUSH,a,Empty,Empty);
    end
    else
      Error_A('Too many params');
    while Lexeme = LEX_COL do
    begin
      Eat(LEX_COL);
      i:=i+1;
      a:=GetExpr;
      if Length(Functions[Objects[PROCID].index].params)>=i then
      begin
        if a.exprtype <> Functions[Objects[PROCID].index].params[i-1].TypePtr then
          Error_A('Can not compare types: ' + '"' + NamedTypes[a.exprtype] + '"' + ' with ' +
            '"' + NamedTypes[Functions[Objects[PROCID].index].params[i-1].typeptr] + '"');
        PutQuad(OP_PUSH,a,Empty,Empty);
      end
      else
        Error_A('Too many params');
    end;
    if Length(Functions[Objects[PROCID].index].params) <> i then
      Error_A('Too few params');
  end
  else
    if Lexeme <> LEX_SEMICOL then
      Error_A('Too many params');
end;

procedure GetAssignment;
var
  a, b: TExprInfo;
begin
  a.exprtype:=TARGETTYPE;
  a.value:=TARGETVALUE;
  a.mode:=TARGETMODE;
  b:=GetExpr;
  if (a.Mode = M_VALUE) then
    Error_A('Left side cannot be assigned to');
  InferType(LEX_ASSIGN,a.exprtype,b.exprtype);
  if a.mode = M_REGISTER then
  begin
    PutQuad(OP_STORE,a,b,Empty);
    ReleaseReg(a.value);
  end
  else begin
    if IsGlobal = false then
      a.value:=-a.value;
    PutQuad(OP_MOV,a,b,Empty);
  end;
  if b.mode = M_REGISTER then
    ReleaseReg(b.value);
end;

procedure GetWhile();
var
  cond:TExprInfo;
  J,J1,J2:integer;
begin
  Eat(LEX_WHILE);
  J1:=Length(code);
  cond:=GetExpr;
  if cond.exprtype <> BOOLEAN_TYPE then
    Error_A('Value must be "boolean"');
  J:=PutQuad(OP_CJMP,cond,Empty,Empty);
  if cond.mode=M_REGISTER then ReleaseReg(cond.value);
  Eat(LEX_DO);
  FixQuad(J,2,J+1);
  GetStatement;
  J2:=PutQuad(OP_JMP,Empty,Empty,Empty);
  FixQuad(J2,1,J1);
  FixQuad(J,3,Length(code));
end;

procedure GetIf;
var
  cond: TExprInfo;
  J,J2: integer;
begin
  Eat(LEX_IF);
  cond:=GetExpr;
  if cond.exprtype <> BOOLEAN_TYPE then
    Error_A('Value must be "boolean"');
  J:=PutQuad(OP_CJMP,cond,Empty,Empty);
  if cond.mode = M_REGISTER then
    ReleaseReg(cond.value);
  Eat(LEX_THEN);
  FixQuad(J,2,J+1);
  GetStatement;
  if Lexeme=LEX_ELSE then
  begin
    Eat(LEX_ELSE);
    J2:=PutQuad(OP_JMP,Empty,Empty,Empty);
    FixQuad(J,3,J2+1);
    GetStatement;
    FixQuad(J2,1,Length(code));
  end
  else
    FixQuad(J,3,Length(code));
end;

procedure GetStatement;
var
  ID, Obj: integer;
  a, d1, d2, d3: TExprInfo;
begin
  case Lexeme of
    LEX_IF:     GetIf;

    LEX_WHILE:  GetWhile;

    LEX_ID: begin
      TmpCh:=CurCh;
      ID:=LexValue;
      Eat(LEX_ID);
      Obj:=FindObject(ID);
      PROCID:=Obj;
      case Objects[Obj].Mode of
        M_VAR: begin
          TARGETTYPE:=Variables[Objects[Obj].index].typeindex;
          TARGETMODE:=M_MEMORY;
          TARGETVALUE:=Variables[Objects[Obj].index].offset;
          if Lexeme = LEX_LKPAREN then
          begin
            Eat(Lexeme);
            a:=GetExpr;
            Eat(LEX_RKPAREN);
            TARGETTYPE:=a.exprtype;
            if a.exprtype <> INTEGER_TYPE then
              Error_A('Index must be "integer"')
            else begin
              case a.mode of
                M_VALUE: begin
                  if Types[Variables[Objects[Obj].index].typeindex].mode=M_ARRAY then
                  begin
                    if (a.value<OrdinalTypes[StaticArray[Types[Variables[Objects[Obj].index].typeindex].index].IndexTypePtr].low)or
                       (a.value>OrdinalTypes[StaticArray[Types[Variables[Objects[Obj].index].typeindex].index].IndexTypePtr].high) then
                      Error_A('Index of array is out of bounds');
                    TARGETTYPE:=StaticArray[Types[Variables[Objects[Obj].index].typeindex].index].BaseTypePtr;
                    TARGETMODE:=M_MEMORY;
                    TARGETVALUE:=Variables[Objects[Obj].index].offset+a.value*SizeOfType(StaticArray[Types[Variables[Objects[Obj].index].typeindex].index].BaseTypePtr);
                  end;
                end; //M_VALUE

                M_MEMORY, M_REGISTER: begin
                  d1.mode:=M_REGISTER;
                  d1.exprtype:=StaticArray[Types[Variables[Objects[Obj].index].typeindex].index].BaseTypePtr;
                  d1.value:=GetFreeRegister;
                  d2.mode:=M_VALUE;
                  d2.exprtype:=0;
                  d2.value:=SizeOfType(StaticArray[Types[Variables[Objects[Obj].index].typeindex].index].BaseTypePtr);
                  PutQuad(OP_MOV,d1,d2,Empty);
                  d3.mode:=M_REGISTER;
                  d3.value:=GetFreeRegister;
                  d3.exprtype:=0;
                  PutQuad(OP_MUL,d1,a,d3);
                  PutQuad(OP_ADD,d3,a,d1);

                  TARGETTYPE:=d1.exprtype;
                  TARGETMODE:=d1.mode;
                  TARGETVALUE:=d1.value;

                  if a.mode=M_REGISTER then
                    ReleaseReg(a.value);
                  ReleaseReg(d3.value);
                end

                else begin
                  Error_A('Variable '+'"'+Identifiers[ID]+'"'+' is not array');
                  TARGETTYPE:=Types[Variables[Objects[Obj].index].typeindex].index;
                end;
              end; //case
            end;
          end; //Lexeme = LEX_LKPAREN
          Eat(LEX_ASSIGN);
          GetAssignment;
        end; // M_VAR
        
        M_PROC, M_FUNCT: begin
          if Lexeme = LEX_LPAREN then
          begin
            Eat(LEX_LPAREN);
            if Objects[Obj].Mode = M_PROC then
              GetActualParam
            else
              GetActualFunParam;
            a.exprtype:=0;
            a.mode:=M_VALUE;
            if Objects[Obj].Mode = M_PROC then
              a.value:=Procedures[Objects[Obj].index].entrypoint
            else
              a.value:=Functions[Objects[Obj].index].entrypoint;
            PutQuad(OP_CALL,a,Empty,Empty);
            Eat(LEX_RPAREN);
          end
          else begin
            if Objects[Obj].Mode = M_PROC then
              GetActualParam
            else
              GetActualFunParam;
            a.exprtype:=0;
            a.mode:=M_VALUE;
            if Objects[Obj].Mode = M_PROC then
              a.value:=Procedures[Objects[Obj].index].entrypoint
            else
              a.value:=Functions[Objects[Obj].index].entrypoint;
            PutQuad(OP_CALL,a,Empty,Empty);
            TARGETTYPE:=0;
          end;
        end;
        // нельзя использовать в Statement
        M_TYPE, M_CONST: Error_A('Statement expected, but expression found.');
        M_PROGR: Error_A('Statement expected, but program name found.');
      end;
    end;

    LEX_BEGIN: GetBlock;
  end;
end;

function GetParamType: integer; forward;

procedure GetParamgroup;
begin
  SetLength(PARAMGROUPLIST,1);
  PARAMGROUPLIST[0]:=LexValue;
  Eat(LEX_ID);
  while Lexeme=LEX_COL do
  begin
    Eat(LEX_COL);
    SetLength(PARAMGROUPLIST,Length(PARAMGROUPLIST)+1);
    PARAMGROUPLIST[Length(PARAMGROUPLIST)-1]:=LexValue;
    Eat(LEX_ID);
  end;
  Eat(LEX_COLON);
  PARAMGROUPLISTTYPE:=GetParamType;
end;

procedure GetParams;
var
  i: integer;
  a: TExprInfo;
begin
  SetLength(PARAMGROUPLIST,0);
  if Lexeme = LEX_LPAREN then
  begin
    Eat(LEX_LPAREN);
    GetParamgroup;
    for i:=Low(PARAMGROUPLIST) to High(PARAMGROUPLIST) do
    begin
      SetLength(PARAMLIST,i+1);
      PARAMLIST[i].nameid:=PARAMGROUPLIST[i];
      PARAMLIST[i].typePtr:=PARAMGROUPLISTTYPE;
      PARAMLIST[i].mode:=M_PARAM_VAR;

      TopScope.allocated:=TopScope.allocated + SizeOfType(PARAMGROUPLISTTYPE);

      NEW_VAR:=NewVar(M_LOCAL,TopScope.allocated,PARAMGROUPLISTTYPE);
      NEW_VAR_OBJ:=NewObject(M_VAR,NEW_VAR);
      EnterObject(PARAMGROUPLIST[i],NEW_VAR_OBJ);

      a.mode:=M_MEMORY;
      a.value:=-TopScope.allocated;
      a.exprtype:=PARAMGROUPLISTTYPE;

      PutQuad(OP_POP,a,Empty,Empty); 
    end;
    while Lexeme = LEX_SEMICOL do
    begin
      SetLength(PARAMGROUPLIST,0);
      Eat(LEX_SEMICOL);
      GetParamgroup;
      for i:=Low(PARAMGROUPLIST) to High(PARAMGROUPLIST) do
      begin
        SetLength(PARAMLIST,Length(PARAMLIST) + i + 1);
        PARAMLIST[Length(PARAMLIST) -1 + i].nameid:=PARAMGROUPLIST[i];
        PARAMLIST[Length(PARAMLIST) -1 + i].typePtr:=PARAMGROUPLISTTYPE;
        PARAMLIST[Length(PARAMLIST) -1 + i].mode:=M_PARAM_VAR;

        TopScope.allocated:=TopScope.allocated + SizeOfType(PARAMGROUPLISTTYPE);

        NEW_VAR:=NewVar(M_LOCAL,TopScope.allocated,PARAMGROUPLISTTYPE);
        NEW_VAR_OBJ:=NewObject(M_VAR,NEW_VAR);
        EnterObject(PARAMGROUPLIST[i],NEW_VAR_OBJ);

        a.mode:=M_MEMORY;
        a.value:=-TopScope.allocated;
        a.exprtype:=PARAMGROUPLISTTYPE;

        PutQuad(OP_POP,a,Empty,Empty);
      end;
    end;
    Eat(LEX_RPAREN);
  end;
end;

function GetParamType: integer;
var
  ID, Obj: integer;
begin
  case Lexeme of
    LEX_ID:
      begin
        ID:=LexValue;
        Eat(LEX_ID);
        Obj:=FindObject(ID);
        if Objects[Obj].mode <> M_TYPE then
        begin
          Error_A('Identifier ' + '"' + IMG[LEX_ID] + '"' + ' is not a type');
          Result:=0;
        end
        else
          Result:=Objects[Obj].index;
      end
    else begin
      Error_A('Identifier ' + '"' + IMG[Lexeme] + '"' + ' is not a type');
      Result:=0;
    end;  
  end;
end;

function GetType: integer;
var
  L, H: TExprInfo;
  ID: integer;
  Obj: integer;
  IdxType, BaseType: integer;
begin
  case Lexeme of
    LEX_ID:
      begin
        ID:=LexValue;
        Eat(LEX_ID);
        Obj:=FindObject(ID);
        if Objects[Obj].mode <> M_TYPE then
        begin
          Error_A('Identifier '+'"' + IMG[LEX_ID] + '"' + ' is not a type');
          Result:=0;
        end
        else
          Result:=Objects[Obj].index;
      end;
    LEX_ARRAY:
      begin
        Eat(LEX_ARRAY);
        EAT(LEX_LKPAREN);
        IdxType:=0;
        L:=GetExpr;
        Eat(LEX_TWODOT);
        H:=GetExpr;
        if not ((L.mode = M_VALUE) and (H.mode = M_VALUE)) then
           Error_A('Identifier is not a type')
        else
          if not(L.exprtype = H.exprtype) then
            Error_A('Can not convert left side to right side')
          else
            if not(Types[L.exprtype].mode = M_SCALAR) then
              Error_A('Type of left side is not a scalar')
            else begin
              ScalarTypes[Types[L.exprtype].index].mode:=M_ORDINAL;
              IdxType:=NewType(M_SCALAR,NewScalar(M_ORDINAL,4,NewOrdinal(L.value,H.value)));
              NewNamedType('ordinal');
            end;
            Eat(LEX_RKPAREN);
            Eat(LEX_OF);
            BaseType:=GetType;
            NewNamedType('array');
            Result:=NewType(M_ARRAY,NewArray(BaseType,ScalarTypes[Types[IdxType].index].index));
      end
    else begin
      Error_A('Identifier ' + '"' + IMG[Lexeme] + '"' + ' is not a type');
      Result:=0;
    end;
  end;
end;

procedure GetIdlist;
begin
  SetLength(IDLIST,1);
  IDLIST[0]:=LexValue;
  Eat(LEX_ID);
  while Lexeme=LEX_COL do
  begin
    Eat(LEX_COL);
    SetLength(IDLIST,Length(IDLIST)+1);
    IDLIST[Length(IDLIST)-1]:=LexValue;
    Eat(LEX_ID);
  end;
end;

procedure GetVargroup;
var
  Typeidx, i: integer;
begin
  GetIdlist;
  Eat(LEX_COLON);
  Typeidx:=GetType;
  for i:=0 to Length(IDLIST)-1 do
  begin
    if IsGlobal then
    begin
      NEW_VAR:=NewVar(M_GLOBAL,TopScope.allocated,Typeidx);
      NEW_VAR_OBJ:=NewObject(M_VAR,NEW_VAR);
      EnterObject(IDLIST[i],NEW_VAR_OBJ);
      TopScope.allocated:=TopScope.allocated + SizeOfType(Typeidx);
    end
    else
    begin
      TopScope.allocated:=TopScope.allocated + SizeOfType(Typeidx);
      NEW_VAR:=NewVar(M_LOCAL,TopScope.allocated,Typeidx);
      NEW_VAR_OBJ:=NewObject(M_VAR,NEW_VAR);
      EnterObject(IDLIST[i],NEW_VAR_OBJ);
    end;
  end;
  SetLength(IDLIST,0);
end;

procedure GetMoreConstDecl;
var
  e: TExprInfo;
  lv, c, oc: integer;
begin
  if Lexeme = LEX_ID then
  begin
    lv:=LexValue;
    Eat(LEX_ID);
    Eat(LEX_EQUAL);
    e:=GetExpr;
    if e.Mode <> M_VALUE then
      Error_A('Constant expression expected.')
    else begin
      c:=NewConst(e.ExprType,e.Value);
      oc:=NewObject(M_CONST,c);
      EnterObject(lv,oc);
    end;
    Eat(LEX_SEMICOL);
    GetMoreConstDecl;
  end
end;

procedure GetConstDecl;
var
  e: TExprInfo;
  lv, c, oc: integer;
begin
  lv:=0;
  Eat(LEX_CONST);
  if Lexeme = LEX_ID then
    lv:=LexValue;
  Eat(LEX_ID);
  Eat(LEX_EQUAL);
  e:=GetExpr;
  if e.Mode <> M_VALUE then
    Error_A('Constant expression expected.')
  else begin
    c:=NewConst(e.ExprType,e.Value);
    oc:=NewObject(M_CONST,c);
    EnterObject(lv,oc);
  end;  
  Eat(LEX_SEMICOL);
  GetMoreConstDecl;
end;

procedure GetVardecl;
begin
  Eat(LEX_VAR);
  while Lexeme = LEX_ID do
  begin
    GetVargroup;
    Eat(LEX_SEMICOL);
  end;
end;

procedure GetNoSubProgDeclaration; forward;

procedure GetProcdecl;
var
  procid, J: integer;
begin
  IsGlobal:=false;
  Eat(LEX_PROC);
  procid:=GetName;
  OpenScope(Identifiers[procid]);
  SetLength(PARAMLIST,0);
  J:=Length(code);
  GetParams;
  Eat(LEX_SEMICOL);

  GetNoSubProgDeclaration;
  GetBlock;
  Eat(LEX_SEMICOL);
  CloseScope;

  NEW_PROC:=NewProcedure(PARAMLIST,J);
  NEW_PROC_OBJ:=NewObject(M_PROC,NEW_PROC);
  EnterObject(procid,NEW_PROC_OBJ);
  
  PutQuad(OP_RET,Empty,Empty,Empty);
  IsGlobal:=true;
end;

procedure GetFunctionDecl;
var
  fid, j, ftype: integer;
begin
  IsGlobal:=false;
  Eat(LEX_FUNCT);
  fid:=GetName;
  OpenScope(Identifiers[fid]);
  j:=Length(code);
  GetParams;
  Eat(LEX_COLON);
  ftype:=GetParamType;
  Eat(LEX_SEMICOL);

  GetNoSubProgDeclaration;

  TopScope.allocated:=TopScope.allocated + SizeOfType(ftype);
  NEW_VAR:=NewVar(M_LOCAL,TopScope.allocated,ftype);
  NEW_VAR_OBJ:=NewObject(M_VAR,NEW_VAR);
  EnterObject(ID_RESULT,NEW_VAR_OBJ);

  GetBlock;
  Eat(LEX_SEMICOL);
  CloseScope;

  NEW_FUNCT:=NewFunction(PARAMLIST,j,ftype);
  NEW_FUNCT_OBJ:=NewObject(M_FUNCT,NEW_FUNCT);
  EnterObject(fid,NEW_FUNCT_OBJ);

  PutQuad(OP_RET,Empty,Empty,Empty);
  IsGlobal:=true;
end;

procedure GetMoreTypeDecl;
var
  t, lv: integer;
begin
  if Lexeme = LEX_ID then
  begin
    lv:=LexValue;
    Eat(LEX_ID);
    Eat(LEX_EQUAL);
    t:=GetType;
    Eat(LEX_SEMICOL);
    EnterObject(lv,NewObject(M_TYPE,t));
    NewNamedType(Identifiers[lv]);
    GetMoreTypeDecl;
  end;
end;

procedure GetTypeDecl;
var
  t, lv: integer;
begin
  lv:=0;
  Eat(LEX_TYPE);
  if Lexeme = LEX_ID then
    lv:=LexValue;
  Eat(LEX_ID);  
  Eat(LEX_EQUAL);
  t:=GetType;
  Eat(LEX_SEMICOL);
  EnterObject(lv,NewObject(M_TYPE,t));
  NewNamedType(Identifiers[lv]);
  GetMoreTypeDecl;
end;

procedure GetDeclaration;  
begin
  case Lexeme of
    LEX_VAR:
      begin
        GetVardecl;
        GetDeclaration;
      end;
    LEX_PROC:
      begin
        GetProcdecl;
        GetDeclaration;
      end;
    LEX_FUNCT:
      begin
        GetFunctionDecl;
        GetDeclaration;
      end;
    LEX_CONST:
      begin
        GetConstDecl;
        GetDeclaration;
      end;
    LEX_TYPE:
      begin
        GetTypeDecl;
        GetDeclaration;
      end;      
  end;
end;

procedure GetNoSubProgDeclaration;
begin
  case Lexeme of
    LEX_VAR:
      begin
        GetVardecl;
        GetNoSubProgDeclaration;
      end;
    LEX_CONST:
      begin
        GetConstDecl;
        GetNoSubProgDeclaration;
      end;
    LEX_TYPE:
      begin
        GetTypeDecl;
        GetNoSubProgDeclaration;
      end;     
    LEX_PROC, LEX_FUNCT:
      begin
        Error_A('"const" or "var" or "type"' + ' expected, but ' + '"' + IMG[Lexeme] + '"' + ' found.');
        Scan;
      end;
  end;
end;

procedure GetBlock;
begin
  Eat(LEX_BEGIN);
  GetStatement;
  while Lexeme = LEX_SEMICOL do
  begin
    Eat(LEX_SEMICOL);
    GetStatement;
  end;
  Eat(LEX_END);
end;

procedure GetProgramm;
var
  s: string;
  l: integer;
begin
  if (Lexeme <> LEX_EOF) then
  begin
    Eat(LEX_PROGR);
    if Lexeme = LEX_ID then
    begin
      s:=Identifiers[LexValue];
      l:=LexValue;
      Eat(LEX_ID);
      Eat(LEX_SEMICOL);
      OpenScope(s);
      EnterObject(l,NewObject(M_PROGR,0));
      if (Lexeme = LEX_PROC) or (Lexeme = LEX_VAR) or (Lexeme = LEX_CONST) or
        (Lexeme = LEX_FUNCT) or (Lexeme = LEX_TYPE) then
        GetDeclaration;
      GetBlock;
      CloseScope();
      PutQuad(OP_HLT,Empty,Empty,Empty);
    end
    else
      Eat(LEX_ID);
  end;
end;

procedure PrintCode(index: integer; Quad: TQuad);
var
  a,b,c,a1,b1,c1:string;
begin
  a:=''; b:=''; c:=''; a1:=''; b1:=''; c1:='';
  case Quad.Oprnd1.mode of
    M_MEMORY:     begin a:='['; a1:=']'; end;
    M_REGISTER:   a:='R';
    M_VALUE:      a:='';
  end;
  case Quad.Oprnd2.mode of
    M_MEMORY:     begin b:='['; b1:=']'; end;
    M_REGISTER:   b:='R';
    M_VALUE:      b:='';
  end;
  case Quad.Res.mode of
    M_MEMORY:     begin c:='['; c1:=']'; end;
    M_REGISTER:   c:='R';
    M_VALUE:      c:='';
  end;
  CodeForm.sgCode.RowCount:=index + 2;
  CodeForm.sgCode.Cells[0,CodeForm.sgCode.RowCount-1]:=OPIMG[Quad.op];
  CodeForm.sgCode.Cells[1,CodeForm.sgCode.RowCount-1]:=a + IntToStr(Quad.Oprnd1.value) + a1;
  CodeForm.sgCode.Cells[2,CodeForm.sgCode.RowCount-1]:=b + IntToStr(Quad.Oprnd2.value) + b1;
  CodeForm.sgCode.Cells[3,CodeForm.sgCode.RowCount-1]:=c + IntToStr(Quad.Res.value) + c1;
end;

procedure CodeClear;
var
  i, j: integer;
begin
  SetLength(Identifiers,0);
  SetLength(Objects,0);
  SetLength(Variables,0);
  SetLength(Constants,0);
  SetLength(Types,0);
  SetLength(ScalarTypes,0);
  SetLength(OrdinalTypes,0);
  SetLength(StaticArray,0);
  SetLength(Procedures,0);
  SetLength(NamedTypes,0);
  SetLength(Functions,0);
  SetLength(code,0);
  MainForm.ListBox.Clear;
  ScopeForm.Memo.Lines.Clear;
  CodeForm.sgCode.Cells[0,0]:='Operator';
  CodeForm.sgCode.Cells[1,0]:='Operand 1';
  CodeForm.sgCode.Cells[2,0]:='Operand 2';
  CodeForm.sgCode.Cells[3,0]:='Result';
  for i:=1 to CodeForm.sgCode.ColCount do
    for j:=2 to CodeForm.sgCode.RowCount do
      CodeForm.sgCode.Cells[i,j]:='';
  CodeForm.sgCode.RowCount:=2;
end;

procedure PrintIds;
var
  i: integer;
begin
  SymForm.Memo.Clear;
  for i:=Low(Identifiers) to High(Identifiers) do
    SymForm.Memo.Lines.Add(IntToStr(i) + ' ' + Identifiers[i]);
  SymForm.Show;  
end;

procedure AllClear;
begin
  MainForm.Memo.Clear;
  CodeClear;
end;

{$R *.dfm}

procedure TMainForm.acExitExecute(Sender: TObject);
begin
  Close();
end;

procedure TMainForm.acCompileExecute(Sender: TObject);
var
  i:integer;
begin
  CodeClear;
  CodeForm.Show;
  ScopeForm.Show;
  TopScope:=nil;
  OpenScope('System');
  SystemScope:=TopScope;

  EnterObject(NewID('unknown type'),NewObject(M_UNKNOWN,NewType(M_SCALAR,NewScalar(M_NOTORDINAL,0,0))));
  NewNamedType('unknown type');

  BOOLEAN_TYPE:=NewType(M_SCALAR,NewScalar(M_ORDINAL,1,NewOrdinal(0,1)));
  BOOLEAN_TYPE_OBJ:=NewObject(M_TYPE,BOOLEAN_TYPE);
  EnterObject(NewID('boolean'),BOOLEAN_TYPE_OBJ);
  NewNamedType('boolean');

  FALSE_CONST:=NewConst(BOOLEAN_TYPE,0);
  FALSE_CONST_OBJ:=NewObject(M_CONST,FALSE_CONST);
  EnterObject(NewID('false'),FALSE_CONST_OBJ);

  TRUE_CONST:=NewConst(BOOLEAN_TYPE,1);
  TRUE_CONST_OBJ:=NewObject(M_CONST,TRUE_CONST);
  EnterObject(NewID('true'),TRUE_CONST_OBJ);

  INTEGER_TYPE:=NewType(M_SCALAR,NewScalar(M_ORDINAL,4,NewOrdinal(-32767,32768)));
  INTEGER_TYPE_OBJ:=NewObject(M_TYPE,INTEGER_TYPE);
  EnterObject(NewID('integer'),INTEGER_TYPE_OBJ);
  NewNamedType('integer');

  SetLength(Identifiers,Length(Identifiers) + 1);
  Identifiers[Length(Identifiers) - 1]:='result';
  ID_RESULT:=High(Identifiers);

  InitScan;
  Scan;
  GetProgramm;
  CloseScope;
  if not(IsError) then
  begin
    for i:=Low(code)to High(code) do
      PrintCode(i,code[i]);
  end;
  PrintIds;
end;

procedure TMainForm.acOpenExecute(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    AllClear;
    Memo.Lines.LoadFromFile(OpenDialog.FileName);
  end;
end;

procedure TMainForm.acNewExecute(Sender: TObject);
begin
  AllClear;
end;

procedure TMainForm.mmiCodeClick(Sender: TObject);
begin
  CodeForm.Show;
end;

procedure TMainForm.mmiScopesClick(Sender: TObject);
begin
  ScopeForm.Show;
end;

procedure TMainForm.mmiSymboltableClick(Sender: TObject);
begin
  PrintIds;
end;

procedure TMainForm.acSaveExecute(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    Memo.Lines.SaveToFile(SaveDialog.FileName + '.txt');
  end;
end;

end.
