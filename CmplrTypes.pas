unit CmplrTypes;

interface

type
  { ���� �������� ���������� 

    M_PROGR   - ���������
    M_VAR     - ����������
    M_CONST   - ���������
    M_TYPE    - ���
    M_PROC    - ���������
    M_FUNCT   - �������
    M_UNKNOWN - ������/����������
   }
  TObjectMode = (M_PROGR, M_VAR, M_CONST, M_TYPE, M_PROC, M_FUNCT, M_UNKNOWN);

  { ������ �������

    Mode  - ��� �������
    Index - ��������� �� ��������������� �������
  }
  TNamedObject = record
    Mode: TObjectMode;
    Index: integer;
  end;

  { ������� ��������� ����������: ���������, ���������� }
  TVarMode = (M_LOCAL, M_GLOBAL);

  { ������ ����������

    Mode      - ���/����
    Offset    - ��������
    Typeindex - ��������� �� ���
  }
  TVariable = record
    Mode: TVarMode;
    Offset: integer;
    Typeindex: integer;
  end;

  { ������ ���������

    Typeindex - ��������� �� ���
    Valueindex - ��������
  }
  TConstant = record
    Typeindex:integer;
    Valueindex:integer;
  end;

  { ���������/������ ����}
  TTypeMode = (M_SCALAR, M_ARRAY);

  { ������ ����

    Mode  - ����/���
    Index - ��������� �� ��������������� �������
  }
  TType = record
    Mode: TTypeMode;
    Index: integer;
  end;

  { ������������/������������ ����}
  TScalarMode = (M_ORDINAL, M_NOTORDINAL);

  { ������ ���������� ����

    Mode  - ��������/���
    Index - ��������� �� ��������������� �������
    Size  - ������  �
  }
  TScalarType = record
    Mode: TScalarMode;
    Index: integer;
    Size: integer;
  end;

  { ������ ������������� ����

    Low  - ������ ������
    High - ������� �������
  }
  TOrdinalType = record
    Low: integer;
    High: integer;
  end;

  { ������ �������

    BaseTypePtr  - ��������� �� ������� ���
    IndexTypePtr - ��������� �� ��� �������
  }
  TArray = record
    BaseTypePtr: integer;
    IndexTypePtr: integer;
  end;

  { �������� ���������� �� ������/�������� }
  TParamMode = (M_PARAM_VAR, M_PARAM_VAL);

  { ������ ��������� ������������

    NameId  -
    TypePtr - ��������� �� ���
    Mode    - ����/���
  }
  TParam = record
    NameId: integer; 
    TypePtr: integer;
    Mode: TParamMode;
  end;

  { ������ ���������

    Params     - ���������
    EntryPoint - ����� �����
  }
  TProcedure = record
    Params: array of TParam;
    EntryPoint: integer;
  end;

  { ������ �������

    Params     - ���������
    EntryPoint - ����� �����
    TypePtr    - ��������� �� ������������ ���
  }
  TFunction = record
    Params: array of TParam;
    EntryPoint: integer;
    TypePtr: integer;
  end;

  { ��� ���������: ��������, ������, ������� }
  TExprMode = (M_VALUE, M_MEMORY, M_REGISTER);

  { ������ ���������

    Mode     - ����/���/���
    Value    - ��������
    Exprtype - ��������� �� ���
  }
  TExprInfo = record
    Mode: TExprMode;
    Value: integer;
    ExprType: integer;
  end;

  { ������ ������� ���������

    Objects   - ������ ��������
    Parent    - ��������� �� ������������ ������� ���������
    Allocated - ���������� ����������������� ������ � �
  }
  PScope = ^TScope;
  TScope = record
    Objects: array of record
      SymPtr: integer;
      ObjPtr: integer;
    end;
    Parent: PScope;
    Allocated: integer;
  end;

  { �������� �������������� ���� ��������� }
  TOperation = (OP_ADD, OP_SUB, OP_MUL, OP_DIV, OP_PUSH, OP_POP, OP_MOV,
                OP_STORE, OP_LOAD, OP_JMP, OP_CJMP, OP_CALL, OP_RET, OP_GT,
                OP_LT, OP_EQ, OP_NE, OP_HLT);

  { ������ �������

    Op                  - ��������
    Oprnd1, Oprnd2, Res - �������1, �������2, ���������
  }
  TQuad = record
    Op: TOperation;
    Oprnd1, Oprnd2, Res: TExprInfo;
  end;

implementation

end.
