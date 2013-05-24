unit CmplrTypes;

interface

type
  { Типы объектов компиляции 

    M_PROGR   - программа
    M_VAR     - переменная
    M_CONST   - константа
    M_TYPE    - тип
    M_PROC    - процедура
    M_FUNCT   - функция
    M_UNKNOWN - ошибка/неизвестно
   }
  TObjectMode = (M_PROGR, M_VAR, M_CONST, M_TYPE, M_PROC, M_FUNCT, M_UNKNOWN);

  { Запись объекта

    Mode  - тип объекта
    Index - указатель на соответствующую таблицу
  }
  TNamedObject = record
    Mode: TObjectMode;
    Index: integer;
  end;

  { Область видимости переменной: локальная, глобальная }
  TVarMode = (M_LOCAL, M_GLOBAL);

  { Запись переменной

    Mode      - лок/глоб
    Offset    - смещение
    Typeindex - указатель на тип
  }
  TVariable = record
    Mode: TVarMode;
    Offset: integer;
    Typeindex: integer;
  end;

  { Запись константы

    Typeindex - указатель на тип
    Valueindex - значение
  }
  TConstant = record
    Typeindex:integer;
    Valueindex:integer;
  end;

  { Скалярный/массив типы}
  TTypeMode = (M_SCALAR, M_ARRAY);

  { Запись типа

    Mode  - скал/мас
    Index - указатель на соответствующую таблицу
  }
  TType = record
    Mode: TTypeMode;
    Index: integer;
  end;

  { Перечислимый/вещественный типы}
  TScalarMode = (M_ORDINAL, M_NOTORDINAL);

  { Запись скалярного типа

    Mode  - перечисл/вещ
    Index - указатель на соответствующую таблицу
    Size  - размер  б
  }
  TScalarType = record
    Mode: TScalarMode;
    Index: integer;
    Size: integer;
  end;

  { Запись перечислимого типа

    Low  - нижняя грница
    High - верхняя граница
  }
  TOrdinalType = record
    Low: integer;
    High: integer;
  end;

  { Запись массива

    BaseTypePtr  - указатель на базовый тип
    IndexTypePtr - указатель на тип индекса
  }
  TArray = record
    BaseTypePtr: integer;
    IndexTypePtr: integer;
  end;

  { Передача параметров по ссылке/значению }
  TParamMode = (M_PARAM_VAR, M_PARAM_VAL);

  { Запись параметра подпрограммы

    NameId  -
    TypePtr - указатель на тип
    Mode    - ссыл/нач
  }
  TParam = record
    NameId: integer; 
    TypePtr: integer;
    Mode: TParamMode;
  end;

  { Запись процедуры

    Params     - параметры
    EntryPoint - точка входа
  }
  TProcedure = record
    Params: array of TParam;
    EntryPoint: integer;
  end;

  { Запись функции

    Params     - параметры
    EntryPoint - точка входа
    TypePtr    - указатель на возвращаемый тип
  }
  TFunction = record
    Params: array of TParam;
    EntryPoint: integer;
    TypePtr: integer;
  end;

  { Тип выражения: значение, памать, регистр }
  TExprMode = (M_VALUE, M_MEMORY, M_REGISTER);

  { Запись выражения

    Mode     - знач/пам/рег
    Value    - значение
    Exprtype - указатель на тип
  }
  TExprInfo = record
    Mode: TExprMode;
    Value: integer;
    ExprType: integer;
  end;

  { Запись области видимости

    Objects   - массив объектов
    Parent    - указатель на родительскую область видимости
    Allocated - количество зарезервированной памяти в б
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

  { Операции промежуточного кода программы }
  TOperation = (OP_ADD, OP_SUB, OP_MUL, OP_DIV, OP_PUSH, OP_POP, OP_MOV,
                OP_STORE, OP_LOAD, OP_JMP, OP_CJMP, OP_CALL, OP_RET, OP_GT,
                OP_LT, OP_EQ, OP_NE, OP_HLT);

  { Запись четвёрки

    Op                  - операция
    Oprnd1, Oprnd2, Res - операнд1, операнд2, результат
  }
  TQuad = record
    Op: TOperation;
    Oprnd1, Oprnd2, Res: TExprInfo;
  end;

implementation

end.
