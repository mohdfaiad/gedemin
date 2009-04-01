
unit gsIBLookupComboBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs,
  StdCtrls, DB, IBHeader, IBDatabase, IBSQL, IBCustomDataSet,
  gsIBLookupComboBoxInterface, gsIBLookupComboBox_dlgDropDown,
  gdcBase, gdcBaseInterface, DBCtrls;

type
  TgsSortOrder = (soNone, soAsc, soDesc);
  TgsViewType = (vtByClass, vtTree, vtGrid);

const
  DefSortOrder = soNone;
  DefCheckUserRights = True;
  DefStrictOnExit = True;
  DefDistinct = False;

type
  TWinControlCrack = class(TWinControl) end;
  TgsIBLookupComboBox = class;

  TgsIBLCBDataLink = class(TFieldDataLink)
  private
    FFirstUse: Boolean;
    FCurrentValue: String;

    function GetCanModify: Boolean;

  protected
    procedure ActiveChanged; override;
    procedure RecordChanged(F: TField); override;

  public
    constructor Create(ALookupComboBox: TgsIBLookupComboBox);
    function Edit: Boolean;
    property CanModify: Boolean read GetCanModify;
  end;

  //
  TOnCreateNewObject = procedure(Sender: TObject; ANewObject: TgdcBase)
    of object;

(*

  ��������� �������� ������� ���� � ���������, ���������
  ���� ListTable, ListField � ������� � ���� DataField
  � DataSource ��������� �������������� �����
  � ���������, ���� ������� � KeyField.
*)

  TgsIBLookupComboBox = class(TCustomComboBox, IgsIBLookupComboBox)
  private
    FKeyField: String;              // ����-���� � �������-�����������
    FListField: String;             // ���� � ������������� �������
    FListTable: String;             // ������� ����������
    FCondition: String;             // ������� ������������� �� ���������� ������
    FSortOrder: TgsSortOrder;       // ���������� ��������
    FCheckUserRights: Boolean;      // ��������� �� ����� ������������
    FNeedsRecheck: Boolean;
    FFields: String;                // ������ ����� ������������ �����������
    FCountAddField: Integer;        // ���������� �������������� �����

    FDataField: String;             // ����, ���� ����������� ��������� ����
    FDataLink: TgsIBLCBDataLink;    // ���� ���������� ������

    FIBBase: TIBBase;
    //FDatabase: TIBDatabase;         // ���� ������
    //FTransaction: TIBTransaction;   // ����������

    Fibsql: TIBSQL;
    //FDontSync: Boolean;

    FCurrentKey: String;            // ������� ����

    FgdClassName: TgdcClassName;
    FgdClass: CgdcBase;

    FdlgDropDown: TdlgDropDown;     // ���������� ����-���
    //FWasDropDownDialog: Boolean;
    FDropDownDialogWidth: Integer;
    FSubType: String;
    FOnCreateNewObject, FOnAfterCreateDialog: TOnCreateNewObject;
    FEmptyCondition: Boolean;
    FParams: TStrings;
    FStrictOnExit: Boolean;
    FDistinct: Boolean;
    FFullSearchOnExit: Boolean;
    FViewType: TgsViewType;

    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetTransaction(const Value: TIBTransaction);
    procedure SetDataSource(const Value: TDataSource);
    function GetDataSource: TDataSource;
    procedure SetDataField(const Value: String);

    procedure SetCurrentKey(const Value: String);
    procedure SetCheckUserRights(const Value: Boolean);
    procedure SetListTable(const Value: String);
    function GetCurrentKeyInt: Integer;
    procedure SetCurrentKeyInt(const Value: Integer);
    function GetValidObject: Boolean;
    procedure SetFields(const Value: String);
    procedure SetListField(const Value: String);
    procedure SetKeyField(const Value: String);
    procedure SetgdClassName(const Value: TgdcClassName);
    procedure SetSubType(const Value: String);

    procedure AssignDropDownDialogSize;
    procedure AssignDropDownDialogExpands;
    procedure SetupDropDownDialog;
    procedure ClearDataField;
    procedure AssignDataField(const AValue: String);

    procedure UpdateListProperties;

    {interface}
    function GetDropDownDialogWidth: Integer;
    procedure SetDropDownDialogWidth(const Value: Integer);
    function GetHandle: HWND;
    function GetgdClassName: TgdcClassName;
    function GetField: TField;
    function GetMainTable: String;
    function GetDatabase: TIBDatabase;
    function GetTransaction: TIBTransaction;
    procedure SetCondition(const Value: String);
    procedure SetReadOnly(const Value: Boolean);
    function GetReadOnly: Boolean;

    procedure SetEditReadOnly;

    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    procedure UpdateHint;
    function GetParams: TStrings;
    function FieldWithAlias(AFieldName: String): String;
    function GetMainTableName: String;
    procedure SetDistinct(const Value: Boolean);
    function GetDistinct: Boolean;
    function GetFullSearchOnExit: Boolean;
    procedure SetFullSearchOnExit(const Value: Boolean);

    procedure ConvertText;
    function GetIsTree: Boolean;
    function GetRestrCondition: String;
    function StripSpaces(const S: String): String;

    function GetTableAlias(const ATableName: String): String;
    procedure SetDisplayText(const AText: String; const AParent: Integer = 0);
    procedure ParseFieldsString(const AFields: String; SL: TStrings);
    function ConvertDate(const S: String): String;

  protected
    procedure DropDown; override;
    procedure Change; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
    //procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    function CreateGDClassInstance(const AnID: Integer): TgdcBase;
    procedure ShowDropDownDialog(const Match: String = ''; const UseExisting: Boolean = False);
    procedure InternalSetCheckUserRights;
    procedure DoExit; override;
    procedure CreateWnd; override;
    {$IFDEF DEBUG}
    procedure DblClick; override;
    {$ENDIF}

    function GetFullCondtion: String;
    procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;

    property FullCondition: String read GetFullCondtion;
    property MainTable: String read GetMainTable;
    property MainTableName: String read GetMainTableName;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure DoLookup(const Exact: Boolean = False;
      const CreateIfNotFound: Boolean = True; const ShowDropDown: Boolean = True;
      Exiting: Boolean = False);
    procedure CreateNew(const FC: TgdcFullClass; const Exiting: Boolean = False);
    procedure ViewForm;
    procedure Edit;
    procedure ObjectProperties;
    procedure Delete;
    procedure Reduce;

    procedure LoadFromStream(S: TStream);
    procedure SaveToStream(S: TStream);
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;

    property CurrentKey: String read FCurrentKey write SetCurrentKey;
    property CurrentKeyInt: Integer read GetCurrentKeyInt write SetCurrentKeyInt;

    //
    property gdClass: CgdcBase read FgdClass;

    {interface}
    property DropDownDialogWidth: Integer read GetDropDownDialogWidth
      write SetDropDownDialogWidth;

    property _Field: TField read GetField;

    //
    property Params: TStrings read GetParams;

    procedure SyncWithDataSource;

    property IsTree: Boolean read GetIsTree;

  published
    property Database: TIBDatabase read GetDatabase write SetDatabase;
    property Transaction: TIBTransaction read GetTransaction write SetTransaction;

    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property DataField: String read FDataField write SetDataField;
    property Fields: String read FFields write SetFields;

    property ListTable: String read FListTable write SetListTable
      stored True;
    property ListField: String read FListField write SetListField
      stored True;
    property KeyField: String read FKeyField write SetKeyField
      stored True;
    property SortOrder: TgsSortOrder read FSortOrder write FSortOrder
      default DefSortOrder;
    property CheckUserRights: Boolean read FCheckUserRights write SetCheckUserRights
      default DefCheckUserRights;
    // ����������: ������ �� � ����� ������������ � ���� ������
    // ��� ���
    property ValidObject: Boolean read GetValidObject;

    //
    property Condition: String read FCondition write SetCondition;

    //
    property gdClassName: TgdcClassName read GetgdClassName write SetgdClassName;
    property SubType: String read FSubType write SetSubType;

    //
    property OnCreateNewObject: TOnCreateNewObject read FOnCreateNewObject write FOnCreateNewObject;
    property OnAfterCreateDialog: TOnCreateNewObject read FOnAfterCreateDialog write FOnAfterCreateDialog;

    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;

    //
    property StrictOnExit: Boolean read FStrictOnExit write FStrictOnExit
      default DefStrictOnExit;

    property Distinct: Boolean read GetDistinct write SetDistinct
      default DefDistinct;

    property FullSearchOnExit: Boolean read GetFullSearchOnExit write SetFullSearchOnExit
      Default False;
      // �� ������ �� ������ ���� True �� ����� �� ������� ����������
      // ���� False �� ���������. �� ��������� �� False

    property ViewType: TgsViewType read FViewType write FViewType default vtByClass;

  published
    property Style; {Must be published before Items}
    property Anchors;
    property BiDiMode;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DropDownCount default 16;
    property Enabled;
    property Font;
    property ImeMode;
    property ImeName;
    property ItemHeight;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnDropDown;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnStartDock;
    property OnStartDrag;

    property Text stored False;
    property Hint stored False;
  end;

  EgsIBLookupComboBoxError = class(Exception);

procedure Register;

procedure DeleteFromLookupCache(const AKey: String);
procedure ClearLookupCache;

implementation

uses
  IB,              gd_security,             at_classes,           jclSysUtils,
  jclStrings,      gsDBGrid,                ContNrs,
  gsDBReduction,   gsIbLookUpComboBox_dlgAction,
  gdc_frmG_unit,
  gdc_frmMDH_unit,
  gdcAttrUserDefined,
  gdcTree, gdcClasses,
  gdHelp_Interface,
  Storages,
  gd_converttext, jclStrHashMap
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  GridRowHeight = 17;
  TreeDelimiterChar = #0187;
  TreeDelimiter = #32 + TreeDelimiterChar + #32;
  TreeDelimiterLen = 3;
  MIN_WIDTH_FOR_TREE = 146; // ����������� ������ ���� ��� ����, ����� �������� ������ ����
                            // � ���������� �������� � ������
  MAX_WIDTH_FOR_AUTO_SET = 600; // ���� ���� ��������� �� �� ����� ���������� ������
                                // ����������� ������ �������������.
  SCROLL_WIDTH = 22;        // ������ ������ �����

var
  FCachedKey: TStringHashMap;

{ TgsIBLookupComboBox }

procedure TgsIBLookupComboBox.Change;
var
  I: Integer;
  S: String;
begin
  if Assigned(Database) and Database.Connected then
  begin
    if (Text <> Items[0]) then
    begin
      if IsTree then
      begin
        S := Text;
        I := 1;
        while I <= Length(S) do
        begin
          if S[I] = TreeDelimiterChar then
          begin
            if (I = 1) or (S[I - 1] <> ' ') then
            begin
              System.Insert(' ', S, I);
              Inc(I);
            end;
            if (I = Length(S)) or (S[I + 1] <> ' ') then
            begin
              Insert(' ', S, I + 1);
              Inc(I);
            end;
          end;
          Inc(I);
        end;
        if S <> Items[0] then
          FCurrentKey := '';
      end else
        FCurrentKey := '';
    end;

    inherited Change;
  end;
end;

constructor TgsIBLookupComboBox.Create(AnOwner: TComponent);
begin
  inherited;
  FIBBase := TIBBase.Create(Self);
  FCountAddField := 0;
  Fibsql := TIBSQL.Create(nil);
  FDataLink := TgsIBLCBDataLink.Create(Self);
  //FDontSync := False;
  FSortOrder := DefSortOrder;
  FCheckUserRights := DefCheckUserRights;
  FNeedsRecheck := False;
  //FWasDropDownDialog := False;
  FdlgDropDown := nil;
  FDropDownDialogWidth := -1;
  FEmptyCondition := False;
  FStrictOnExit := DefStrictOnExit;
  FViewType := vtByClass;
  FDistinct := False;
  HelpContext := 1;

  ControlStyle := ControlStyle + [csReplicatable];
  DropDownCount := 16;
  UpdateHint;
end;

destructor TgsIBLookupComboBox.Destroy;
begin
  FreeAndNil(FIBSQL);
  FDataLink.Free;
  FreeAndNil(FdlgDropDown);
  FreeAndNil(FIBBase);
  FParams.Free;
  inherited;
end;

procedure TgsIBLookupComboBox.SetCurrentKey(const Value: String);
var
  Found: Boolean;
  OldKey: String;
  DistinctStr: String;

  procedure PrepareSQL;
  var
    I: Integer;
  begin
    if (Transaction = nil) or (not Transaction.InTransaction) then
      Fibsql.Transaction := gdcBaseManager.ReadTransaction
    else
      Fibsql.Transaction := Transaction;

    if FDistinct then
      DistinctStr := 'DISTINCT'
    else
      DistinctStr := '';

    Fibsql.Close;
    Fibsql.SQL.Text := Format('SELECT %4:s %0:s, %1:s FROM %2:s WHERE (%3:s = :V) ',
      [FieldWithAlias(FListField), FieldWithAlias(FKeyField),
       FListTable, FieldWithAlias(FKeyField), DistinctStr]);

    if FNeedsRecheck then
      InternalSetCheckUserRights;

    if FCheckUserRights and Assigned(IBLogin)
      and (not IBLogin.IsUserAdmin) then
    begin
      Fibsql.SQL.Text := Fibsql.SQL.Text + Format(' AND (g_sec_test(%s.aview, %d) <> 0) ', [MainTable, IBLogin.InGroup]);
    end;

    if FullCondition > '' then
      Fibsql.SQL.Text := Fibsql.SQL.Text + ' AND (' + FullCondition + ') ';

    if (FgdClass <> nil) {and (AnsiCompareText(FListTable, FgdClass.GetListTable(FSubType)) = 0)}
      and (tiDisabled in FgdClass.GetTableInfos(FSubType))
      and (GetTableAlias(FgdClass.GetListTable(FSubType)) > '') then
    begin
      Fibsql.SQL.Text := Format('%s AND ((%1:s.disabled IS NULL) OR (%1:s.disabled = 0))',
        [Fibsql.SQL.Text, GetTableAlias(FgdClass.GetListTable(FSubType))]);
    end;

    Fibsql.Prepare;
    Fibsql.ParamByName('V').AsString := Value;

    for I := 0 to Fibsql.Params.Count - 1 do
    begin
      if Fibsql.Params[I].Name <> 'V' then
      begin
        if (FParams = nil) or (FParams.IndexOfName(Fibsql.Params[I].Name) = -1) then
          raise Exception.Create('TgsIBLookupComboBox: Invalid param name');
        Fibsql.Params[I].AsString := FParams.Values[Fibsql.Params[I].Name];
      end;
    end;
  end;

begin
  Found := False;
  OldKey := FCurrentKey;

  // �������� ��������, ��� � �������� �� �� ���������
  // ��������������� = -1, ������� ���� �� ����� ��������
  // ��������� ������ � ���� ������ � ����� ������
  if (Value > '') {$IFDEF GEDEMIN} and (Value <> '-1') {$ENDIF} then
  begin
    PrepareSQL;
    Fibsql.ExecQuery;

    if (Fibsql.RecordCount = 0)
      and Assigned(DataSource)
      and (DataSource.DataSet is TIBCustomDataSet)
      and (TIBCustomDataSet(DataSource.DataSet).Transaction <> nil)
      and (TIBCustomDataSet(DataSource.DataSet).Transaction.InTransaction) then
    begin
      Fibsql.Close;
      Fibsql.Transaction := TIBCustomDataSet(DataSource.DataSet).Transaction;
      PrepareSQL;
      Fibsql.ExecQuery;
    end;

    if Fibsql.RecordCount = 1 then
    begin
      FCurrentKey := Value;
      SetDisplayText(Fibsql.Fields[0].AsTrimString);
      AssignDataField(Value);
      Found := True;

      DeleteFromLookupCache(FCurrentKey);
    end;

    Fibsql.Close;
  end;

  if not Found then
  begin
    FCurrentKey := '';
    Items[0] := '';
    ItemIndex := 0;
    ClearDataField;
  end;

  if OldKey <> FCurrentKey then
    if Assigned(OnChange) then OnChange(Self);
end;

procedure TgsIBLookupComboBox.DoLookup(const Exact: Boolean = False;
  const CreateIfNotFound: Boolean = True; const ShowDropDown: Boolean = True;
  Exiting: Boolean = False);
var
  S, SText: String;
  StrFields: String;
  MessageBoxResult, I, J: Integer;
  SL: TStringList;
  CL: TClassList;
  SelectCondition: String;
  DistinctStr: String;
  Found: Boolean;
  NewClass: CgdcBase;
  dlgAction: TgsIBLkUp_dlgAction;
begin
  {if (FListTable = '') or (FListField = '') or (FKeyField = '') then
    exit;}

  if (not Assigned(Database)) or (not Database.Connected) then
    exit;

  FCurrentKey := '';

  SetupDropDownDialog;

  SText := Text;
  while Pos('''', SText) > 0 do
    System.Delete(SText, Pos('''', SText), 1);
  if IsTree and (Pos(TreeDelimiterChar, SText) > 0) then
  begin
    I := Pos(TreeDelimiterChar, SText) + 1;
    repeat
      J := Pos(TreeDelimiterChar, Copy(SText, I, 1024));
      if J = 0 then
        break;
      I := I + J;
    until False;
    SText := Copy(SText, I, 1024);
    if (Length(SText) > 0) and (SText[1] = ' ') then
      System.Delete(SText, 1, 1);
  end;
  Text := SText;

  if FFields > '' then
    StrFields := ', ' + FieldWithAlias(FFields)
  else
    StrFields := '';

  if (gdClass <> nil) and IsTree then
    StrFields := StrFields + ', ' + FieldWithAlias(CgdcTree(gdClass).GetParentField(SubType));

  if FDistinct then
    DistinctStr := 'DISTINCT'
  else
    DistinctStr := '';

  if Text > '' then
  begin

    S := Format('SELECT %4:s %0:s, %1:s %2:s FROM %3:s WHERE',
      [FieldWithAlias(FListField), FieldWithAlias(FKeyField),
      StrFields, FListTable, DistinctStr]);

    if Exact then
      SelectCondition := Format(' (%0:s = ''%1:s'') ', [FieldWithAlias(FListField), Text])
    else
      SelectCondition := Format('(UPPER(%0:s) LIKE ''%%%1:s%%'') ',
        [FieldWithAlias(FListField), _AnsiUpperCase(ConvertDate(Text))]);

    if FFields > '' then
    begin
      SL := TStringList.Create;
      try
        ParseFieldsString(FFields, SL);
        for J := 0 to SL.Count - 1 do
        begin
          if Exact then
            SelectCondition := Format('%s OR (%s = ''%s'') ',
              [SelectCondition, FieldWithAlias(Trim(SL[J])), Text])
          else
            SelectCondition := Format('%s OR (UPPER(COALESCE(%s, '''')) LIKE ''%%%s%%'') ',
              [SelectCondition, FieldWithAlias(Trim(SL[J])), _AnsiUpperCase(ConvertDate(Text))])
        end;      
      finally
        SL.Free;
      end;
    end;
    S := Format('%s (%s)', [S, SelectCondition])
  end else
    S := Format('SELECT %4:s %0:s, %1:s %2:s FROM %3:s ',
      [FieldWithAlias(FListField), FieldWithAlias(FKeyField),
       StrFields, FListTable, DistinctStr]);

  if FullCondition > '' then
    if Text > '' then
      S := S + ' AND (' + FullCondition + ') '
    else
      S := S + ' WHERE ' + FullCondition + ' ';

  if FNeedsRecheck then
    InternalSetCheckUserRights;

  if FCheckUserRights and Assigned(IBLogin)
    and (not IBLogin.IsUserAdmin) then
  begin
    if Pos('WHERE ', S) = 0 then
      S := S + Format(' WHERE (g_sec_test(%s.aview, %d) <> 0) ', [MainTable, IBLogin.InGroup])
    else
      S := S + Format(' AND (g_sec_test(%s.aview, %d) <> 0) ', [MainTable, IBLogin.InGroup]);
  end;

  if (FgdClass <> nil) {and (AnsiCompareText(FListTable, FgdClass.GetListTable(FSubType)) = 0)}
    and (tiDisabled in FgdClass.GetTableInfos(FSubType)) then
  begin
    if GetTableAlias(FgdClass.GetListTable(FSubType)) > '' then
    begin
      if Pos('WHERE ', S) = 0 then
        S := S + ' WHERE '
      else
        S := S + ' AND ';

      S := Format('%s ((%1:s.disabled IS NULL) OR (%1:s.disabled = 0))',
        [S, GetTableAlias(FgdClass.GetListTable(FSubType))]);
    end;
  end;

  if FSortOrder = soAsc then
    S := S + ' ORDER BY ' + FieldWithAlias(FListField) + ' ASC '
  else if FSortOrder = soDesc then
    S := S + ' ORDER BY ' + FieldWithAlias(FListField) + ' DESC ';

  FdlgDropDown.ibdsList.Close;
  FdlgDropDown.ibdsList.SelectSQL.Text := S;

  FdlgDropDown.ibdsList.Prepare;

  for I := 0 to FdlgDropDown.ibdsList.Params.Count - 1 do
  begin
    if (FParams = nil) or (FParams.IndexOfName(FdlgDropDown.ibdsList.Params[I].Name) = -1) then
      raise Exception.Create('TgsIBLookupComboBox: Invalid param name');
    FdlgDropDown.ibdsList.Params[I].AsString :=
      FParams.Values[FdlgDropDown.ibdsList.Params[I].Name];
  end;

  try
    FdlgDropDown.ibdsList.Open;
  except
    on E: EIBError do
    begin
      if E.IBErrorCode = 335544334 then
      begin
        MessageBox(0,
          '��� ����������� � ���������� ������ ���������� �������� ��������� ����.'#13#10 +
          '��� ��������� �� ��������� ���� � ������� ��������� CAST.'#13#10 +
          '��������: CAST(z.documentdate AS VARCHAR(10))',
          '��������',
          MB_ICONHAND or MB_TASKMODAL or MB_OK);
      end;

      raise;
    end;
  end;

  // ����� ���, ��� ���� �����������
  // ��� ����� ���� ����! ���� �� ������� ���� �� ���� Next
  // �� �������� RecordCount ����� ���������� 0, ���� ibsql ������,
  // ��� 1 (������), ���� ibsql �������� ������
  // � ������ ������ (����) ���� �������� RecordCount = 0, >1, =1
  if not FdlgDropDown.ibdsList.EOF then
    FdlgDropDown.ibdsList.Next;

  if FdlgDropDown.ibdsList.RecordCount = 0 then
  begin
    NewClass := nil;
    if CreateIfNotFound then
    begin
      if gdClass = nil then
        MessageBoxResult := IDYES
      else
      begin
        if Text > '' then
        begin
          if Self.Owner is TCustomForm then
            dlgAction := TgsIBLkUp_dlgAction.Create(Self.Owner)
          else
            dlgAction := TgsIBLkUp_dlgAction.Create(Self);
          with dlgAction do
          try
            lblText.Caption := Format(lblText.Caption, [Self.Text]);

            cb.Visible := False;
            if (gdClass <> nil) and (SubType = '') then
            begin
              CL := TClassList.Create;
              try
                if gdClass.GetChildrenClass(CL) then
                begin
                  if not gdClass.IsAbstractClass then
                  begin
                    if CL.IndexOf(gdClass) = -1 then
                      CL.Add(gdClass);
                  end;

                  for I := CL.Count - 1 downto 0 do
                  begin
                    if CgdcBase(CL[I]).IsAbstractClass then
                      CL.Delete(I);
                  end;

                  if CL.Count > 0 then
                  begin
                    for I := 0 to CL.Count - 1 do
                    begin
                      Found := False;
                      for J := 0 to CL.Count - 1 do
                      begin
                        if J = I then
                          continue;
                        if CgdcBase(CL[I]).GetDisplayName(SubType) = CgdcBase(CL[J]).GetDisplayName(SubType) then
                        begin
                          Found := True;
                          break;
                        end;
                      end;

                      if Found then
                        cb.Items.AddObject(CgdcBase(CL[I]).GetDisplayName(SubType) +
                          ' (' + CL[I].ClassName + ')',
                          Pointer(CL[I]))
                      else
                        cb.Items.AddObject(CgdcBase(CL[I]).GetDisplayName(SubType),
                          Pointer(CL[I]));
                    end;
                  end;

                  cb.Visible := True;
                  if CL.Count > 1 then
                    cb.ItemIndex := 0
                  else
                    cb.ItemIndex := 1;
                end;
              finally
                CL.Free;
              end;
            end;

            case UserStorage.ReadInteger('Options', 'LkupDef', 1, False) of
              1: ActiveControl := btnList;
              3: ActiveControl := btnClose;
            else
              if cb.Visible then
                ActiveControl := cb
              else
                ActiveControl := btnCreate;
            end;

            if Exiting and UserStorage.ReadBoolean('Options', 'AutoCreate', False, False)
              and Assigned(gdClass) and (not gdClass.InheritsFrom(TgdcDocument)) then
            begin
              MessageBoxResult := IDNO;
            end else
            begin
              Exiting := False;
              case ShowModal of
                mrOk:
                begin
                  MessageBoxResult := IDYES;
                  if Assigned(gdClass) and gdClass.InheritsFrom(TgdcTree)
                    and (ViewType <> vtGrid) then
                  begin
                    Text := ''; // � ��������� ������, �� ����� ��������� �� ������, � ������
                  end;
                  UserStorage.WriteInteger('Options', 'LkupDef', 1);
                end;

                mrYes:
                begin
                  if cb.Visible and (cb.ItemIndex > 0) then
                    NewClass := CgdcBase(cb.Items.Objects[cb.ItemIndex]);
                  MessageBoxResult := IDNO;
                  UserStorage.WriteInteger('Options', 'LkupDef', 2);
                end;
              else
                MessageBoxResult := IDCANCEL;
                UserStorage.WriteInteger('Options', 'LkupDef', 3);
              end;
            end;
          finally
            Free;
          end;
          {
          MessageBoxResult := MessageBox(Handle,
            '�� ������� �� ������ �������, ����������������'#13#10 +
            '���������� �������� ������. ������� ���� ������?'#13#10 +
            #13#10 +
            '��������:'#13#10 +
            '�� -- ������� ������ ���� ��������.'#13#10 +
            '��� -- ������� ����� ������.'#13#10 +
            '������ -- ������� ��� ����.',
            '��������!',
            MB_YESNOCANCEL or MB_ICONQUESTION or MB_TASKMODAL);
          }
        end else
        begin
          MessageBoxResult := MessageBox(Handle,
            '������ ��� ������ ����. ������� ����� ������?',
            '��������!',
            MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL);
          if MessageBoxResult = IDYES then
            MessageBoxResult := IDNO
          else
            MessageBoxResult := IDCANCEL;
        end;
      end;

      if MessageBoxResult = IDYES then
        ShowDropDownDialog
      else if MessageBoxResult = IDNO then
        CreateNew(gdcFullClass(NewClass, SubType), Exiting)
      else begin
        S := Text;
        ClearDataField;
        Text := S;
        SelStart := 0;
        SelLength := Length(Text);
        SetFocus;
      end;
    end;
  end
  else if ShowDropDown or ((FdlgDropDown.ibdsList.RecordCount > 1) and CreateIfNotFound) then
  begin
    ShowDropDownDialog('', True);
  end else if (FdlgDropDown.ibdsList.RecordCount = 1) then
  begin
    FCurrentKey := FdlgDropDown.dsList.DataSet.Fields[1].AsString;
    SetDisplayText(Trim(FdlgDropDown.dsList.DataSet.Fields[0].AsString));
    AssignDataField(FCurrentKey);
    if Assigned(OnChange) then
      OnChange(Self);

    DeleteFromLookupCache(FCurrentKey);
  end;
end;

procedure TgsIBLookupComboBox.DropDown;
begin
  if not ((csDesigning in ComponentState))
    and Assigned(Database)
    and Database.Connected then
  begin
    if ValidObject then
      ShowDropDownDialog
    else
      DoLookup;
  end;    
end;

function TgsIBLookupComboBox.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TgsIBLookupComboBox.LoadFromStream(S: TStream);
var
  R: TReader;
begin
  R := TReader.Create(S, 128);
  try
    try
      if (R.NextValue <> vaInt32) or (R.ReadInteger <> $56789914) then exit;
      FDropDownDialogWidth := R.ReadInteger;
    except
      FDropDownDialogWidth := -1;
    end;
  finally
    R.Free;
  end;
end;

procedure TgsIBLookupComboBox.SaveToStream(S: TStream);
var
  W: TWriter;
begin
  W := TWriter.Create(S, 128);
  try
    W.WriteInteger($56789914);
    W.WriteInteger(FDropDownDialogWidth);
  finally
    W.Free;
  end;
end;

procedure TgsIBLookupComboBox.SetDatabase(const Value: TIBDatabase);
begin
  if Database <> Value then
  begin
    if Database <> nil then
      Database.RemoveFreeNotification(Self);
    FIBBase.Database := Value;
    Fibsql.Database := Database;
    if Assigned(Value) then
      Value.FreeNotification(Self);
  end;
  if (not Assigned(Transaction)) and Assigned(Database) then
    Transaction := Database.DefaultTransaction;
end;

procedure TgsIBLookupComboBox.SetDataField(const Value: String);
begin
  if FDataField <> Trim(Value) then
  begin
    FDataField := Trim(Value);
    if (FSubType > '') and (FgdClassName > '') then
      UpdateListProperties;
    FDataLink.FieldName := FDataField;
    //SyncWithDataSource;
  end;
end;

procedure TgsIBLookupComboBox.SetDataSource(const Value: TDataSource);
begin
  if FDataLink.DataSource <> Value then
  begin
    FDataLink.DataSource := Value;
    if (FSubType > '') and (FgdClassName > '') then
      UpdateListProperties;
    SyncWithDataSource;
  end;
end;

procedure TgsIBLookupComboBox.SetTransaction(const Value: TIBTransaction);
begin
  if Transaction <> Value then
  begin
    if Assigned(Transaction) then
      Transaction.RemoveFreeNotification(Self);
    FIBBase.Transaction := Value;
    Fibsql.Transaction := Transaction;
    if Assigned(Value) then
    begin
      Value.FreeNotification(Self);
      if (CurrentKey > '') and (FDataLink.Field <> nil) and (not FDataLink.Field.ReadOnly) then
        SetCurrentKey(CurrentKey)
      else
        SyncWithDataSource;  
    end;
  end;
  if (not Assigned(Database)) and Assigned(Transaction) then
    Database := Transaction.DefaultDatabase;
end;

procedure TgsIBLookupComboBox.SyncWithDataSource;
var
  I: Integer;
  S: String;
  P: PChar;
begin
  if ((ComponentState * [csDesigning, csLoading, csDestroying]) <> [])
    or (Assigned(Owner) and (csLoading in Owner.ComponentState))
    or (not Assigned(Parent))
    or (not Visible) then
  begin
    exit;
  end;

  if not Assigned(Transaction)
    and (DataSource <> nil)
    and (DataSource.DataSet is TgdcBase)
    and ((DataSource.DataSet as TgdcBase).Transaction <> nil) then
  begin
    Transaction := (DataSource.DataSet as TgdcBase).Transaction;
  end;

  FCurrentKey := '';
  Items[0] := '';
  ItemIndex := 0;

  if (FDataField > '')
    and Assigned(FDataLink.DataSet)
    and FDataLink.DataSet.Active
    and (FListField > '')
    and (FListTable > '')
    and (FKeyField > '')
    and (FDataLink.DataSet.FindField(FDataField) <> nil)
    and (not (FDataLink.DataSet.FieldByName(FDataField).IsNull)) then
  begin
    // cache start
    S := '';
    if FCachedKey.Find(FDataLink.DataSet.FieldByName(FDataField).AsString, P) then
    begin
      I := Pos('#', P);
      if AnsiCompareText(FListField, Copy(P, 1, I - 1)) = 0 then
        S := Copy(P, I + 1, 255);
    end;

    if S > '' then
    begin
      FCurrentKey := FDataLink.DataSet.FieldByName(FDataField).AsString;
      Items[0] := S;
      ItemIndex := 0;
    end else
    // cache end
    begin
      if (Transaction = nil) or (not Transaction.InTransaction) then
        Fibsql.Transaction := gdcBaseManager.ReadTransaction
      else
        Fibsql.Transaction := Transaction;
      Fibsql.Close;

      if IsTree and Assigned(gdClass) and (GetTableAlias(gdClass.GetListTable(FSubType)) > '') then
        Fibsql.SQL.Text := Format('SELECT %s, %s.%s FROM %s WHERE %s = :V ',
          [FieldWithAlias(FListField),
           GetTableAlias(gdClass.GetListTable(FSubType)),
           CgdcTree(gdClass).GetParentField(SubType),
           FListTable,
           FieldWithAlias(FKeyField)])
      else begin
        I := Pos('.', FKeyField);
        Fibsql.SQL.Text := Format('SELECT %0:s FROM %1:s WHERE %2:s=:V ',
          [FListField, MainTableName, Copy(FKeyField, I + 1, 255)]);
      end;
      try
        Fibsql.Prepare;
      except
        { TODO :
����� ��� ��������� ��� ���  ������������ ������
� ���� ����� ����� ���� �� ������� ������ -- � �����
������. ���� ������ ��������� ��.
����� ��������� ��� �� �����? }
        exit;
      end;
      Fibsql.ParamByName('V').AsString :=
        FDataLink.DataSet.FieldByName(FDataField).AsString;
      Fibsql.ExecQuery;

      if (Fibsql.RecordCount = 0)
        and Assigned(DataSource)
        and (DataSource.DataSet is TIBCustomDataSet)
        and (TIBCustomDataSet(DataSource.DataSet).Transaction <> nil)
        and (TIBCustomDataSet(DataSource.DataSet).Transaction.InTransaction) then
      begin
        Fibsql.Close;
        Fibsql.Transaction := TIBCustomDataSet(DataSource.DataSet).Transaction;

        try
          Fibsql.Prepare;
        except
          { TODO :
    ����� ��� ��������� ��� ���  ������������ ������
    � ���� ����� ����� ���� �� ������� ������ -- � �����
    ������. ���� ������ ��������� ��.
    ����� ��������� ��� �� �����? }
          exit;
        end;
        Fibsql.ParamByName('V').AsString :=
          FDataLink.DataSet.FieldByName(FDataField).AsString;
        Fibsql.ExecQuery;
      end;

      if Fibsql.RecordCount > 0 then
      begin
        FCurrentKey :=
          FDataLink.DataSet.FieldByName(FDataField).AsString;
        if Fibsql.Current.Count = 1 then
          SetDisplayText(Fibsql.Fields[0].AsTrimString)
        else
          SetDisplayText(Fibsql.Fields[0].AsTrimString, Fibsql.Fields[1].AsInteger);

        // cache start
        if not FCachedKey.Has(FDataLink.DataSet.FieldByName(FDataField).AsString) then
        begin
          S := FListField + '#' + Items[0];
          GetMem(P, Length(S) + 1);
          StrPCopy(P, S);
          FCachedKey.Add(FDataLink.DataSet.FieldByName(FDataField).AsString, P);
        end;
        // cache end
      end;

      Fibsql.Close;
    end;
  end;

  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TgsIBLookupComboBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if Operation = opRemove then
  begin
    if AComponent = FDlgDropDown then
      FDlgDropDown := nil;

    if Assigned(FIBBase) and (AComponent = FIBBase.Database) then
    begin
      FIBBase.Database := nil;
    end;

    if Assigned(FIBsql) and (AComponent = FIBsql.Database) then
    begin
      Fibsql.Database := nil;
    end;
  end;
end;

procedure TgsIBLookupComboBox.CreateNew(const FC: TgdcFullClass;
  const Exiting: Boolean = False);
var
  T2, obj: TgdcBase;
  C: TgdcFullClass;
  CurrKey: Integer;
  WasCancel: Boolean;

  function _CreateDialog: Boolean;
  var
    I: Integer;
    ShowDialog: Boolean;
  begin
    if Exiting
      and (Pos('%', Text) = 0)
      and (Pos('_', Text) = 0) then
    begin
      ShowDialog := False;

      if Assigned(UserStorage) then
      begin
        if not UserStorage.ValueExists('Options', 'AutoCreate', False) then
        begin
          ShowDialog := MessageBox(Handle,
            '��������� ������� �������������, ���� ��� �� ������� � ������?',
            '��������',
            MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL or MB_DEFBUTTON2) = IDNO;
          UserStorage.WriteBoolean('Options', 'AutoCreate', not ShowDialog);
          MessageBox(Handle,
            '�� ������ �������� ����� �������� �������� � ������ ���������.',
            '��������',
            MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
        end else
          ShowDialog := not UserStorage.ReadBoolean('Options', 'AutoCreate', False, False);
      end;

      if not ShowDialog then
      begin
        for I := 0 to Obj.FieldCount - 1 do
        begin
          if Obj.Fields[I].Required and Obj.Fields[I].IsNull then
          begin
            ShowDialog := True;
            break;
          end;
        end;

        if not ShowDialog then
        try
          Obj.Post;
        except
          ShowDialog := True;
        end;
      end;
    end else
      ShowDialog := True;  

    if ShowDialog then
      Result := Obj.CreateDialog
    else
      Result := True;

    WasCancel := not Result;
  end;

begin
  if (not Assigned(Database)) or (not Database.Connected) then
    exit;

  WasCancel := False;
  T2 := CreateGDClassInstance(-1);
  if Assigned(T2) then
  try
    CurrKey := -1;
    if FC.gdClass = nil then
      C := T2.QueryDescendant
    else
      C := FC;
    if C.gdClass <> nil then
    begin
      if (T2.ClassType = C.gdClass) and (T2.SubType = FSubType) then
        Obj := T2
      else
        Obj := C.gdClass.CreateSubType(Owner, FSubType, 'ByID');
      try
        Obj.Open;
        Obj.Insert;
        if (CurrentKey = '') and (Text > '') then
        begin
          if Obj.FindField(ListField) <> nil then
          try
            Obj.FieldByName(ListField).AsString := Text;
          except
          end;
        end;
        if Assigned(FOnCreateNewObject) then
          FOnCreateNewObject(Self, Obj);
        if (Obj.State = dsBrowse) or _CreateDialog then
        begin
          if Assigned(FOnAfterCreateDialog) then
            FOnAfterCreateDialog(Self, Obj);
          CurrKey := Obj.ID;
        end;
      finally
        if Obj <> T2 then
          Obj.Free;
      end;
      if WasCancel and (CurrentKey = '') then
        CurrentKeyInt := -1
      else
      begin
        if CurrKey <> -1 then
        begin
          CurrentKeyInt := CurrKey;
          if (CurrKey > -1) and (CurrentKey = '') then
            MessageBox(0,
              '������ ���������� ����������.'#13#10#13#10 +
              '�������� ��� ���� ������� ��� ���������� ������'#13#10 +
              '�� ������������� �������� ������,'#13#10 +
              '�������������� � ���������� ������.',
              '��������',
              MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        end;
      end;  
    end;
  finally
    T2.Free;
  end;
end;

procedure TgsIBLookupComboBox.Edit;
var
  T2: TgdcBase;
begin
  if (not Assigned(Database)) or (not Database.Connected) then
    exit;

  if CurrentKeyInt = -1 then
  begin
    DoLookup(False, True, False, False);
    if CurrentKeyInt = -1 then
      exit;
  end;

  T2 := CreateGDClassInstance(CurrentKeyInt);
  if Assigned(T2) then
  try
    if T2.EditDialog then
    begin
      CurrentKey := CurrentKey;
      DeleteFromLookupCache(FCurrentKey);
    end;
  finally
    T2.Free;
  end;
end;

procedure TgsIBLookupComboBox.Delete;
var
  T2: TgdcBase;
  OldCurrentKey: String;
begin
  if (not Assigned(Database)) or (not Database.Connected) then
    exit;

  if CurrentKeyInt = -1 then
  begin
    DoLookup(False, True, False, False);
    if CurrentKeyInt = -1 then
      exit;
  end;

  if MessageBox(Handle,
    PChar('�� ������������� ������ ������� ������ "' + Text + '"?'),
    '��������',
    MB_YESNO or MB_ICONQUESTION) = IDNO then
  begin
    exit;
  end;

  T2 := CreateGDClassInstance(CurrentKeyInt);
  if Assigned(T2) then
  try
    OldCurrentKey := CurrentKey;
    try
      CurrentKey := '';
      T2.Delete;
    except
      CurrentKey := OldCurrentKey;
      raise;
    end;
  finally
    T2.Free;
  end;
end;

procedure TgsIBLookupComboBox.ShowDropDownDialog(const Match: String = ''; const UseExisting: Boolean = False);
var
  S, StrFields: String;
  W: TWinControl;
  I, J: Integer;
  SL: TStringList;
  SelectCondition: String;
  DistinctStr: String;
  WasActive: Boolean;
  LF: String;
begin
  SetupDropDownDialog;
  if FdlgDropDown.dsList.DataSet <> FdlgDropDown.ibdsList then
    FdlgDropDown.dsList.DataSet := FdlgDropDown.ibdsList;

  WasActive := FdlgDropDown.ibdsList.ReadTransaction.InTransaction;

  try
    if not UseExisting then
    begin
      if FFields > '' then
        StrFields := ', ' + FieldWithAlias(FFields)
      else
        StrFields := '';

      if (gdClass <> nil) and IsTree then
        StrFields := StrFields + ', ' + MainTable + '.' + CgdcTree(gdClass).GetParentField(SubType);

      if FDistinct then
        DistinctStr := 'DISTINCT'
      else
        DistinctStr := '';

      S := Format('SELECT %4:s %0:s, %1:s %2:s FROM %3:s ', [FieldWithAlias(FListField),
        FieldWithAlias(FKeyField), StrFields, FListTable, DistinctStr]);

      if Match > '' then
      begin
        SelectCondition := Format(' (UPPER(%0:s) LIKE ''%%%1:s%%'') ',
          [FieldWithAlias(FListField), _AnsiUpperCase(ConvertDate(Match))]);

        if FFields > '' then
        begin
          SL := TStringList.Create;
          try
            ParseFieldsString(FFields, SL);
            for J := 0 to SL.Count - 1 do
              SelectCondition := Format('%s OR (UPPER(COALESCE(%s, '''')) LIKE ''%%%s%%'') ',
                [SelectCondition, FieldWithAlias(Trim(SL[J])), _AnsiUpperCase(ConvertDate(Match))])
          finally
            SL.Free;
          end;
        end;
        S := Format('%s WHERE (%s)', [S, SelectCondition])
      end;

      if FullCondition > '' then
        if Pos('WHERE ', S) = 0 then
          S := S + ' WHERE (' + FullCondition + ') '
        else
          S := S + ' AND (' + FullCondition + ') ';

      if FNeedsRecheck then
        InternalSetCheckUserRights;

      if FCheckUserRights and Assigned(IBLogin)
        and (not IBLogin.IsUserAdmin) then
      begin
        if Pos('WHERE ', S) = 0 then
          S := S + Format(' WHERE (g_sec_test(%s.aview, %d) <> 0) ', [MainTable, IBLogin.InGroup])
        else
          S := S + Format(' AND (g_sec_test(%s.aview, %d) <> 0) ', [MainTable, IBLogin.InGroup]);
      end;

      if (FgdClass <> nil) {and (AnsiCompareText(FListTable, FgdClass.GetListTable(FSubType)) = 0)}
        and (tiDisabled in FgdClass.GetTableInfos(FSubType)) then
      begin
        if GetTableAlias(FgdClass.GetListTable(FSubType)) > '' then
        begin
          if Pos('WHERE ', S) = 0 then
            S := S + ' WHERE '
          else
            S := S + ' AND ';

          S := Format('%s ((%1:s.disabled IS NULL) OR (%1:s.disabled = 0))',
            [S, GetTableAlias(FgdClass.GetListTable(FSubType))]);
        end;    
      end;

      if FSortOrder = soAsc then
        S := S + ' ORDER BY ' + FieldWithAlias(FListField) + ' ASC '
      else if FSortOrder = soDesc then
        S := S + ' ORDER BY ' + FieldWithAlias(FListField) + ' DESC ';

      FdlgDropDown.ibdsList.Close;
      FdlgDropDown.ibdsList.SelectSQL.Text := S;
      FdlgDropDown.ibdsList.Prepare;

      for I := 0 to FdlgDropDown.ibdsList.Params.Count - 1 do
      begin
        if (FParams = nil) or (FParams.IndexOfName(FdlgDropDown.ibdsList.Params[I].Name) = -1) then
          raise Exception.Create('TgsIBLookupComboBox: Invalid param name');
        FdlgDropDown.ibdsList.Params[I].AsString :=
          FParams.Values[FdlgDropDown.ibdsList.Params[I].Name];
      end;

      FdlgDropDown.ibdsList.Open;
    end;

    if FdlgDropDown.ibdsList.IsEmpty then
    begin

      MessageBox(Self.Handle,
        '������ ��� ������ ����.',
        '��������!',
        MB_OK or MB_ICONINFORMATION);

      Items[0] := '';
      ItemIndex := 0;
      SetFocus;

    end else
    begin
      while (not FdlgDropDown.ibdsList.EOF) and (FdlgDropDown.ibdsList.RecordCount < DropDownCount) do
        FdlgDropDown.ibdsList.Next;

      AssignDropDownDialogSize;
      AssignDropDownDialogExpands;

      MAX_LOCATE_WAIT := 7000;
      try
        if ValidObject then
        begin
          if not FdlgDropDown.dsList.DataSet.Locate(FKeyField, FCurrentKey, []) then
            FdlgDropDown.dsList.DataSet.First;
        end else
        begin
          I := Pos('.', FListField);
          if I = 0 then
            LF := FListField
          else
            LF := Copy(FListField, I + 1, 255);

          if (FdlgDropDown.dsList.DataSet.RecordCount >= DropDownCount)
            or (not FdlgDropDown.dsList.DataSet.Locate(LF, Text, [loCaseInsensitive])) then
          begin
            FdlgDropDown.dsList.DataSet.First;
          end;
        end;
      finally
        MAX_LOCATE_WAIT := $FFFFFFFF;
      end;

      FdlgDropDown.FLastKey := 0;
      if FdlgDropDown.ShowModal = mrOk then
      begin
        if FCurrentKey <> FdlgDropDown.dsList.DataSet.Fields[1].AsString then
        begin
          FCurrentKey := FdlgDropDown.dsList.DataSet.Fields[1].AsString;
          SetDisplayText(Trim(FdlgDropDown.dsList.DataSet.Fields[0].AsString));
          AssignDataField(FCurrentKey);
        end else
        begin
          if Assigned(OnChange) {and (FdlgDropDown.FLastKey = 0)} then
          begin
            OnChange(Self);
            Repaint;
          end;
        end;  

        DeleteFromLookupCache(FCurrentKey);

        if FdlgDropDown.FWasTabKey and (Parent is TWinControl) then
        begin
          W := Parent;
          while W.Parent <> nil do
            W := W.Parent;

          TWinControlCrack(W).SelectNext(Self, True, True);
        end else
          SetFocus;
      end;
      if FdlgDropDown.FLastKey <> 0 then
        PostMessage(Self.Handle,  WM_KEYDOWN, FdlgDropDown.FLastKey, 0);
    end;
  finally
    if (not WasActive) and FdlgDropDown.ibdsList.ReadTransaction.InTransaction then
      FdlgDropDown.ibdsList.ReadTransaction.Commit;
  end;
end;

procedure TgsIBLookupComboBox.SetCheckUserRights(const Value: Boolean);
begin
  if FCheckUserRights <> Value then
  begin
    FCheckUserRights := Value;
    InternalSetCheckUserRights;
  end;  
end;

procedure TgsIBLookupComboBox.InternalSetCheckUserRights;
var
  I: Integer;
begin
(*
  ��� ��������� ����� ������������� �� ���� ���� ��������� ���
  ���������� ������ ��� ���������� ����.
*)
  if FCheckUserRights and (ComponentState * [csDesigning] = []) then
  begin
    if (FgdClass <> nil) and (FgdClass.GetListTable(FSubType) = FListTable) then
      FCheckUserRights := tiAView in FgdClass.GetTableInfos(FSubType)
    else if Assigned(atDatabase) and (FListTable > '') then
    begin
      I := Pos(' ', FListTable) - 1;
      if I = -1 then I := Length(FListTable);
      FCheckUserRights :=
        atDatabase.FindRelationField(Copy(FListTable, 1, I), 'aview') <> nil;
    end;
    FNeedsRecheck := False;
  end else
    FNeedsRecheck := csDesigning in ComponentState;
end;

procedure TgsIBLookupComboBox.SetListTable(const Value: String);
var
  FC: TgdcFullClass;
  I: Integer;
begin
  if FListTable <> Trim(Value) then
  begin
    FListTable := Trim(Value);
    InternalSetCheckUserRights;
    if FDataField > '' then
      SyncWithDataSource;

    if (not (csDesigning in ComponentState))
      and (FgdClassName = '') and (FListTable > '') then
    begin
      I := Pos(' ', FListTable) - 1;
      if I = -1 then I := Length(FListTable);
      FC := GetBaseClassForRelation(Copy(FListTable, 1, I));
      FgdClass := FC.gdClass;
      FSubType := FC.SubType;
      if FgdClass <> nil then
        FgdClassName := FgdClass.ClassName;
      UpdateHint;
    end;
  end;
end;

procedure TgsIBLookupComboBox.DoExit;
var
  Pt: TPoint;
  W: TWinControl;
begin
  try
    FDataLink.UpdateRecord;
  except
    SetFocus;
    raise;
  end;

  // ��� ������������ ����� ������ ��������� -- ����� �������� ��� �� ������
  if (not (csDesigning in ComponentState))
    and (
      ((Text > '') and (FCurrentKey = ''))
      or
      ((Items.Count > 0) and (Items[0] <> Text))
    )
//    and (not ReadOnly)
  then
  begin
    GetCursorPos(Pt);
    W := FindVCLWindow(Pt);
    if ((W <> nil) and (W is TButton) and TButton(W).Cancel)
      or ((Owner is TForm) and (TForm(Owner).ModalResult = mrCancel)) then
    begin
      if FCurrentKey = '' then
        Items[0] := '';
      ItemIndex := 0;
    end else
    begin
      if Text > '' then
        DoLookup(FFullSearchOnExit, FStrictOnExit, False, True)
      else
      begin
        FCurrentKey := '';
        Items[0] := '';
        ItemIndex := 0;
        ClearDataField;
      end;
    end;  
  end;

  inherited;

  if SelStart > 0 then
    SelStart := 0;
end;

function TgsIBLookupComboBox.GetCurrentKeyInt: Integer;
begin
  Result := StrToIntDef(FCurrentKey, -1);
end;

procedure TgsIBLookupComboBox.SetCurrentKeyInt(const Value: Integer);
begin
  CurrentKey := IntToStr(Value);
end;

function TgsIBLookupComboBox.GetValidObject: Boolean;
begin
  Result := FCurrentKey > '';
end;

function TgsIBLookupComboBox.GetFullCondtion: String;
var
  RestrCondition: String;
//  I: Integer;
begin
  if Assigned(FgdClass) and (FCondition = '')
    and (FgdClass.GetListTable(FSubType) = FListTable) then
  begin
    RestrCondition := GetRestrCondition;
  //  I := Pos(' ', FListTable)  - 1;
  //  if I = -1 then I := Length(FListTable);
  //  RestrCondition := FgdClass.GetRestrictCondition(Copy(FListTable, 1, I), FSubType);
  //  RestrCondition := StringReplace(RestrCondition, FgdClass.GetListTableAlias + '.', '', [rfReplaceAll, rfIgnoreCase]);
  end else
    RestrCondition := '';

  if RestrCondition > '' then
    Result := iff(FCondition > '', FCondition + ' AND ', '') + RestrCondition
  else
    Result := FCondition;

  // ������� �� ������� ������ �������, ������� ����� � ��� �������
  // �� �������� ������
  {if Assigned(FgdClass) then
    while Pos(FgdClass.GetListTableAlias + '.', Result) > 0 do
    begin
      System.Delete(Result, Pos(FgdClass.GetListTableAlias + '.', Result),
        Length(FgdClass.GetListTableAlias) + 1);
    end;}
end;

procedure TgsIBLookupComboBox.Reduce;
begin
  if (not Assigned(Database)) or (not Database.Connected) then
    exit;

  {
  if Assigned(atDatabase)
    and (atDatabase.Relations.ByRelationName('RPL$LOG') <> nil) then
  begin
    MessageBox(0,
      '����������� ������� ����������, ��� ��� ��������� ����� ����������.',
      '��������',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    exit;
  end;
  }

  if Assigned(GlobalStorage) and Assigned(IBLogin)
    and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_REDUCT_ID, GD_POL_REDUCT_MASK, False) and IBLogin.InGroup) = 0) then
  begin
    raise EgdcUserHaventRights.Create(
      '����������� ������� ��������� �������� ����������� �������� ������������.');
  end;

  with TgsDBReductionWizard.Create(Self) do
  try
    HideFields := 'LB;RB;AFULL;ACHAG;AVIEW';
    Condition := Self.FullCondition;
    Database := Self.Database;
    ListField := Self.ListField;
    MasterKey := Self.CurrentKey;
    Table := Self.ListTable;
    Transaction := Self.Transaction;
    TransferData := True;
    Wizard;

    // ���� � ������� ������� �������, �������
    // ������ ������ � ������
    CurrentKey := CurrentKey;
  finally
    Free;
  end;
end;

procedure TgsIBLookupComboBox.SetFields(const Value: String);
var
  I: Integer;
begin
  if FFields <> Value then
  begin
    FFields := StringReplace(Trim(Value), ';', ',', [rfReplaceAll]);
    FCountAddField := 0;
    if FFields > '' then
    begin
      Inc(FCountAddField);
      for I := 1 to Length(FFields) - 1 do { -1 to allow strings like aaa;bbb; }
        if FFields[i] = ',' then Inc(FCountAddField);
    end;
  end;
end;

procedure TgsIBLookupComboBox.SetListField(const Value: String);
begin
  if FListField <> Trim(Value) then
  begin
    if StrContainsChars(Value, [',', ';'], False) then
      raise EgsIBLookupComboBoxError.Create('Invalid List field name specified');
    FListField := Trim(Value);
    if FDataField > '' then
    begin
      FCurrentKey := '';
      SyncWithDataSource;
    end;
  end;
end;

procedure TgsIBLookupComboBox.SetKeyField(const Value: String);
begin
  if FKeyField <> Trim(Value) then
  begin
    if StrContainsChars(Value, [',', ';'], False) then
      raise EgsIBLookupComboBoxError.Create('Invalid List field name specified');
    FKeyField := Trim(Value);
    if FDataField > '' then
      SyncWithDataSource;
  end;
end;

function TgsIBLookupComboBox.CreateGDClassInstance(const AnID: Integer): TgdcBase;
var
  C: TPersistentClass;
  SL: TStringList;
  I: Integer;
  F: Boolean;
begin
  C := GetClass(gdClassName);
  if Assigned(C) and (C.InheritsFrom(TgdcBase)) then
  begin
    if FSubType > '' then
    begin
      SL := TStringList.Create;
      try
        CgdcBase(C).GetSubTypeList(SL);

        F := False;
        for I := 0 to SL.Count - 1 do
        begin
          if Pos('=' + FSubType + '^', SL[I] + '^') > 0 then
          begin
            F := True;
            break;
          end;
        end;

        if not F then
          raise Exception.Create('gsIBLookupComboBox: invalid subtype specified'#13#10 +
             'Class: ' + FgdClassName + #13#10'Subtype: ' + FSubType);
      finally
        SL.Free;
      end;
    end;

    Result := CgdcBase(C).CreateSubType(Self.Owner, FSubType, 'ByID');
    Result.ID := AnID;
    if Result.ID <> -1 then
    begin
      Result.Open;

      if Result.IsEmpty then
      begin
        MessageBox(Handle,
          PChar('���������� ������� ��������� ������ ������� � ������� ������.'#13#10 +
          '��������� ������������ ������� ����� ������, ������� �������, � ����� ����������, '#13#10 +
          '�� ������� �������� ���������� ������.'),
          '��������',
          MB_OK or MB_ICONHAND);
        Abort;
      end;
    end;
  end else
    Result := nil;
end;

procedure TgsIBLookupComboBox.SetgdClassName(const Value: TgdcClassName);
begin
  if FgdClassName <> Value then
  begin
    if not (csDesigning in ComponentState) then
    begin
      if (Value > '') and ((FindClass(Value) = nil) or (not FindClass(Value).InheritsFrom(TgdcBase))) then
        raise Exception.Create(Value + ' is not a valid gdc class!');
    end;    

    FgdClassName := Value;
    FreeAndNil(FdlgDropDown);
    UpdateListProperties;
    InternalSetCheckUserRights;
    SyncWithDataSource;
  end;
end;

procedure TgsIBLookupComboBox.AssignDropDownDialogSize;
var
  Hg, NewHg, Rc, I, W, HeightTemp: Integer;
  DC: HDC;
  OldF: THandle;
  P: TSize;
  TempS: String;
  RDesk: TRect;
begin
  if Assigned(Parent) and (Parent is TControl) then
  begin
    FdlgDropDown.Left := (Parent as TControl).ClientToScreen(Point(Left, Top + Height)).X;
    FdlgDropDown.Top := (Parent as TControl).ClientToScreen(Point(Left, Top + Height)).Y;
  end;
  if FDropDownDialogWidth = -1 then
  begin
    FdlgDropDown.Width := Width - 1;
    if FdlgDropDown.tv.Visible then
    begin
      W := FdlgDropDown.tv.MaxWidth;
    end else
    begin
      W := 0;
      DC := GetDC(0);
      OldF := SelectObject(DC, FdlgDropDown.gsDBGrid.TableFont.Handle);
      try
        I := 0;
        FdlgDropDown.dsList.DataSet.First;
        while (I < DropDownCount) and (not FdlgDropDown.dsList.DataSet.EOF) do
        begin
          TempS := FdlgDropDown.dsList.DataSet.Fields[0].AsString;
          GetTextExtentPoint(DC, @TempS[1], Length(TempS), P);
          if P.cx > W then
            W := P.cx;
          Inc(I);
          FdlgDropDown.dsList.DataSet.Next;
        end;
        FdlgDropDown.dsList.DataSet.First;
      finally
        SelectObject(DC, OldF);
        ReleaseDC(0, DC);
      end;
    end;
    if (FdlgDropDown.Width - SCROLL_WIDTH < W)
      and (W < MAX_WIDTH_FOR_AUTO_SET) then
    begin
      FdlgDropDown.Width := W + SCROLL_WIDTH;
    end;
  end;
  if FdlgDropDown.dsList.DataSet.RecordCount < DropDownCount then
    Rc := FdlgDropDown.dsList.DataSet.RecordCount
  else
    Rc := DropDownCount;
  { TODO : � ���� ������, ������ ��������� �� ���������! }
  Hg := Rc * GridRowHeight * (FCountAddField + 1) + 16;
  NewHg := Abs(Font.Height) * (Rc * (FCountAddField + 1) + 2);
  if Hg < NewHg then
    Hg := NewHg;

  SystemParametersInfo(SPI_GETWORKAREA, 0, @RDesk, 0);
  FdlgDropDown.Height := Hg;
  HeightTemp := FdlgDropDown.Height + FdlgDropDown.Top;

  if FdlgDropDown.Height + FdlgDropDown.Top > RDesk.Bottom then
  // �������� �������, ��� ������ �����
  begin
    if (RDesk.Bottom - FdlgDropDown.Top) >= FdlgDropDown.Top then
      FdlgDropDown.Height := FdlgDropDown.Height - HeightTemp + RDesk.Bottom
    else begin
      FdlgDropDown.Top := (Parent as TControl).ClientToScreen(Point(Left,
        Self.Top - FdlgDropDown.Height)).Y;
      if FdlgDropDown.Top < 0 then
      begin
        FdlgDropDown.Height := FdlgDropDown.Height + FdlgDropDown.Top - RDesk.Top;
        FdlgDropDown.Top := RDesk.Top + 1;
      end;
    end;
  end;

  if FdlgDropDown.Width + FdlgDropDown.Left > RDesk.Right then
  begin
    //��������, ��� ������ �����
    if (RDesk.Right - FdlgDropDown.Left) >= FdlgDropDown.Left then
      FdlgDropDown.Width := RDesk.Right - FdlgDropDown.Left
    else begin
      FdlgDropDown.Left := RDesk.Right - FdlgDropDown.Width;
      if FdlgDropDown.Left < 0 then
      begin
        FdlgDropDown.Width := FdlgDropDown.Width  + FdlgDropDown.Left - RDesk.Left;
        FdlgDropDown.Left := RDesk.Left + 1;
      end;
    end;
  end;
end;

procedure TgsIBLookupComboBox.AssignDropDownDialogExpands;
var
  I, J: Integer;
  ColumnExpand: TColumnExpand;
  ParentField, LF: String;
begin
  with FdlgDropDown do
  begin
    if gsDBGrid.Enabled then
    begin
      if (gdClass <> nil) and gdClass.InheritsFrom(TgdcTree) then
        ParentField := CgdcTree(gdClass).GetParentField(SubType)
      else
        ParentField := '';

      I := Pos('.', FListField);
      if I = 0 then
        LF := FListField
      else
        LF := Copy(FListField, I + 1, 255);

      J := Pos('.', FKeyField);

      gsDBGrid.Expands.Clear;
      for I := 0 to dsList.DataSet.Fields.Count - 1 do
      begin
        if ((AnsiCompareText(Copy(FKeyField, J + 1, 255), dsList.DataSet.Fields[I].FieldName) = 0)
            or
            (AnsiCompareText(ParentField, dsList.DataSet.Fields[I].FieldName) = 0))
           and
           (AnsiCompareText(LF, dsList.DataSet.Fields[I].FieldName) <> 0)
        then
        begin
          gsDBGrid.ColumnByField(dsList.DataSet.Fields[I]).Visible := False;
          continue;
        end;

        if ANSICompareText(FListField, FKeyField) = 0 then
          continue;

        if (AnsiCompareText(LF, dsList.DataSet.Fields[I].FieldName) = 0) then
        begin
          gsDBGrid.ColumnByField(dsList.DataSet.Fields[I]).Visible := True;
          continue;
        end;

        ColumnExpand := gsDBGrid.Expands.Add;
        ColumnExpand.DisplayField := dsList.DataSet.Fields[0].FieldName;
        ColumnExpand.FieldName := dsList.DataSet.Fields[I].FieldName;
        ColumnExpand.Options := [ceoAddField];
        gsDBGrid.ColumnByField(dsList.DataSet.Fields[I]).Visible := False;
      end;
      gsDBGrid.ExpandsActive := True;
    end;
  end;
end;

procedure TgsIBLookupComboBox.SetupDropDownDialog;
var
  Cl: Integer;
begin
  // ���������� ���� �� ����������� �������������� �������
  // ������ ���� ���
  if not Assigned(FdlgDropDown) then
    FdlgDropDown := TdlgDropDown.Create(Self);
  FdlgDropDown.FIBLookup := Self;
  if (gdClass <> nil)
    and IsTree
    and ((Text = '') or ValidObject) then
  begin
    FdlgDropDown.tv.KeyField := gdClass.GetKeyField(SubType);
    FdlgDropDown.tv.ParentField := CgdcTree(gdClass).GetParentField(SubType);
    FdlgDropDown.tv.DisplayField := FListField;//gdClass.GetListField(SubType);

    FdlgDropDown.tv.Visible := True;
    FdlgDropDown.tv.Enabled := True;
    FdlgDropDown.tv.Font := Font;

    FdlgDropDown.gsDBGrid.Visible := False;
    FdlgDropDown.gsDBGrid.Enabled := False;
  end else begin
    FdlgDropDown.tv.Visible := False;
    FdlgDropDown.tv.Enabled := False;
    FdlgDropDown.gsDBGrid.Visible := True;
    FdlgDropDown.gsDBGrid.Enabled := True;
    Cl := FdlgDropDown.gsDBGrid.TableFont.Color;
    FdlgDropDown.gsDBGrid.TableFont := Font;
    FdlgDropDown.gsDBGrid.TableFont.Color := Cl;
    Cl := FdlgDropDown.gsDBGrid.SelectedFont.Color;
    FdlgDropDown.gsDBGrid.SelectedFont := Font;
    FdlgDropDown.gsDBGrid.SelectedFont.Color := Cl;
  end;
  if not FdlgDropDown.ibdsList.Active then
  begin
    FdlgDropDown.ibdsList.Database := Database;
    FdlgDropDown.ibdsList.Transaction := Transaction;
  end;
end;

procedure TgsIBLookupComboBox.ClearDataField;
begin
  {FDontSync := True;
  try}
    if FDataLink.Active and (not FDataLink.DataSet.IsEmpty)
      and FDataLink.Edit and
      (not FDataLink.DataSet.FieldByName(FDataField).IsNull) then
    begin
      FDataLink.DataSet.FieldByName(FDataField).Clear;
    end
    else if (FDataLink.Field <> nil) and (FDataLink.Field.ReadOnly)
      and (not FDataLink.Field.IsNull) then
    begin
      MessageBox(Handle,
        '���������� ��������� �������� ����, ��� ��� ��� ��������� � ��������� ������ ��� ������.',
        '��������',
        MB_OK or MB_ICONEXCLAMATION);
    end;    
  {finally
    FDontSync := False;
  end;}
end;

procedure TgsIBLookupComboBox.AssignDataField(const AValue: String);
begin
  {FDontSync := True;
  try}
    if FDataLink.Active and FDataLink.Edit then
    begin
      {if FDataLink.DataSet.FieldByName(FDataField).AsString <> AValue then}
        FDataLink.DataSet.FieldByName(FDataField).AsString := AValue;
    end
    else if (FDataLink.Field <> nil) and (FDataLink.Field.ReadOnly) then
    begin
      MessageBox(Handle,
        '���������� ��������� �������� ����, ��� ��� ��� ��������� � ��������� ������ ��� ������.',
        '��������',
        MB_OK or MB_ICONEXCLAMATION);
    end else
      if Assigned(OnChange) then
        OnChange(Self);
  {finally
    FDontSync := False;
  end;}
end;

procedure TgsIBLookupComboBox.CreateWnd;
begin
  inherited;
  Items.Add('');
end;

function TgsIBLookupComboBox.GetDropDownDialogWidth: Integer;
begin
  Result := FDropDownDialogWidth;
end;

procedure TgsIBLookupComboBox.SetDropDownDialogWidth(const Value: Integer);
begin
  FDropDownDialogWidth := Value;
end;

function TgsIBLookupComboBox.GetHandle: HWND;
begin
  Result := Handle;
end;

procedure TgsIBLookupComboBox.SetSubType(const Value: String);
begin
  if FSubType <> AnsiUpperCase(Value) then
  begin
    FSubType := AnsiUpperCase(Value);
    UpdateListProperties;
    InternalSetCheckUserRights;
    SyncWithDataSource;
  end;
end;

procedure TgsIBLookupComboBox.UpdateListProperties;
var
  C: TPersistentClass;
  F: TatRelationField;
  I: Integer;
  Origin: String;
begin
  C := GetClass(FgdClassName);

  if Assigned(C) and C.InheritsFrom(TgdcBase) then
  begin
    FgdClass := CgdcBase(C);

    { TODO : ������������ � �������! ������� ���� ����������� �������, ����� ����, � �� ��������! }
    if (FgdClass.GetListTable(FSubType) > '') and (FListTable = '') then
      FListTable := FgdClass.GetListTable(FSubType);

    if (FgdClass.GetListField(FSubType) > '') then
    begin
      //
      // �������� �������� ���� ��� ��������� �� ���������,
      // ���� ��� ������ - ���������� ���� �� �������� ������

      if
        Assigned(DataSource) and
        Assigned(DataSource.DataSet) and
        DataSource.DataSet.Active and
        (DataSource.DataSet.FindField(FDataField) <> nil) and
        Assigned(atDatabase) then
      begin
        Origin := DataSource.DataSet.FieldByName(FDataField).Origin;
        I := AnsiPos('.', Origin);

        F := atDatabase.FindRelationField(
          Copy(Origin, 1, I - 1),
          Copy(Origin, I + 1, Length(Origin))
        );
      end else
        F := nil;

      if FListField = '' then
      begin
        if not Assigned(F) or (F.Field.RefListFieldName = '') then
          FListField := FgdClass.GetListField(FSubType)
        else
          FListField := F.Field.RefListFieldName;
      end;
    end;

    if (FKeyField = '') and (FgdClass.GetKeyField(FSubType) > '') then
      FKeyField := FgdClass.GetKeyField(FSubType);

    if (FCondition = '')
      and (not FEmptyCondition)
      and (FgdClass.GetListTable(FSubType) = FListTable)
      and (GetRestrCondition > '') then
    begin
      FCondition := GetRestrCondition;
    end;

    if (FFields = '') and (FgdClass.GetListFieldExtended(FSubType) > '') then
      Fields := FgdClass.GetListFieldExtended(FSubType);
  end else
  begin
    FgdClass := nil;
  end;

  UpdateHint;
  ShowHint := Screen.Width >= 640; // �������� ���� �� ������
end;

procedure TgsIBLookupComboBox.ViewForm;
var
  C: TPersistentClass;
  F: TForm;
begin
  C := GetClass(gdClassName);
  if Assigned(C) and (C.InheritsFrom(TgdcBase)) then
  begin
    F := CgdcBase(C).CreateViewForm(Application, '', FSubType, True);
    try
      if Assigned(F) then
      begin
        MessageBox(0,
          '��� ������ ������� ���������� �� ���� ������ � �������� ����.'#13#10#13#10 +
          '��������� ������ �������, ��������� ���� � ����� ��������� �'#13#10 +
          '������, ����� ���� ���������� � ���������� ������.'#13#10 +
          '',
          '����� �������',
          MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);

        F.ShowModal;

        if MessageBox(0,
          '�� ������������� ���� �����?',
          '��������',
          MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
        begin
          if (F is Tgdc_frmMDH) and ((F as Tgdc_frmMDH).gdcDetailObject <> nil) then
          begin
            if C.InheritsFrom((F as Tgdc_frmMDH).gdcDetailObject.ClassType)
              and ((F as Tgdc_frmMDH).gdcDetailObject.ID > 0) then
            begin
              CurrentKeyInt := (F as Tgdc_frmMDH).gdcDetailObject.ID;
            end else if ((F as Tgdc_frmMDH).gdcObject <> nil) and
              C.InheritsFrom((F as Tgdc_frmMDH).gdcObject.ClassType)
            then
              CurrentKeyInt := (F as Tgdc_frmMDH).gdcObject.ID
          end else if (F is Tgdc_frmG) and ((F as Tgdc_frmG).gdcObject <> nil) then
            CurrentKeyInt := (F as Tgdc_frmG).gdcObject.ID;
        end;
      end;
    finally
      F.Free;
    end;
  end;
end;

function TgsIBLookupComboBox.GetgdClassName: TgdcClassName;
begin
  Result := FgdClassName;
end;

procedure TgsIBLookupComboBox.ObjectProperties;
var
  T2: TgdcBase;
begin
  if (not Assigned(Database)) or (not Database.Connected) then
    exit;

  if CurrentKeyInt = -1 then
  begin
    DoLookup(False, True, False, False);
  end;

  if (CurrentKeyInt = -1) then
    exit
  else if (gdClass = nil) then
  begin
    MessageBox(Handle,
      PChar(CurrentKey),
      '������������� ��������� ������',
      MB_OK or MB_ICONINFORMATION);
  end else
  begin
    T2 := CreateGDClassInstance(CurrentKeyInt);
    if Assigned(T2) then
    try
      if T2.EditDialog('Tgdc_dlgObjectProperties') then
      begin
        Text := T2.ObjectName;
        AssignDataField(CurrentKey);
        if Assigned(OnChange) then
          OnChange(Self);
      end;
    finally
      T2.Free;
    end;
  end;
end;

function TgsIBLookupComboBox.GetField: TField;
begin
  if (FDataLink.DataSet <> nil) and (FDataLink.DataSet.FindField(FDataField) <> nil) then
    Result := FDataLink.DataSet.FieldByName(FDataField)
  else
    Result := nil;
end;

function TgsIBLookupComboBox.GetMainTable: String;
var
  i: Integer;
begin
//��������� �������� ����� ������� �������
//������� ������� ������ ���� ������!!!
//���� ���� ��������� ������, �� ��� �� ������ ����������� �������!!!!
  i := Pos(' ', FListTable);
  if i = 0 then
    Result := FListTable
  else
    Result := GetTableAlias(Copy(FListTable, 1, I - 1));
end;

function TgsIBLookupComboBox.GetMainTableName: String;
var
  i: Integer;
begin
  i := Pos(' ', Trim(FListTable));
  if i = 0 then
    Result := FListTable
  else
    Result := Copy(Trim(FListTable), 1, i - 1);
{$IFDEF DEBUG}
  if Pos(' ', FListTable) = 1 then
    ShowMessage(FListTable);
{$ENDIF}
end;

function TgsIBLookupComboBox.GetDatabase: TIBDatabase;
begin
  Result := FIBBase.Database;
  if (Result = nil) and (Transaction <> nil) then
    Result := Transaction.DefaultDatabase;
end;

function TgsIBLookupComboBox.GetTransaction: TIBTransaction;
begin
  Result := FIBBase.Transaction;
end;

procedure TgsIBLookupComboBox.SetCondition(const Value: String);
begin
  FCondition := Value;
  FEmptyCondition := (csLoading in ComponentState) and (FCondition = '');
{  if not (csLoading in ComponentState) then
  try
    SetCurrentKey(CurrentKey);
  except
    on E: EIBError do
    begin
      // ��������� ������, ������� ����� ���� ������� � ���,
      // ��� � ���� Condition ��������� �� ������ �������
      // �������� ��� ��������� ������������ Condition
      if (E.IBErrorCode <> isc_dsql_error) then
        raise;
    end else
      raise;
  end;}
end;

procedure TgsIBLookupComboBox.SetReadOnly(const Value: Boolean);
begin
  FDataLink.ReadOnly := Value;
  SetEditReadOnly;
end;

function TgsIBLookupComboBox.GetReadOnly: Boolean;
begin
  Result := FDataLink.ReadOnly;
end;

procedure TgsIBLookupComboBox.CNCommand(var Message: TWMCommand);
begin
  if not ReadOnly then
    case Message.NotifyCode of
      CBN_DROPDOWN: PostMessage(Handle, WM_KEYDOWN, VK_DOWN, 0);
      else inherited;
    end;
end;

procedure TgsIBLookupComboBox.SetEditReadOnly;
begin
  if (Style in [csDropDown, csSimple]) and HandleAllocated then
    SendMessage(EditHandle, EM_SETREADONLY, Ord(not FDataLink.CanModify), 0);
end;

procedure TgsIBLookupComboBox.UpdateHint;
begin
  if FgdClass <> nil then
    Hint := '����������� �������: '#13#10 +
            '  F1     -- ����� ������� '#13#10 +
            '  F2     -- �������� ������ ������� '#13#10 +
            '  F3     -- ����� '#13#10 +
            '  F4     -- ��������� ���������� ������� '#13#10 +
            '  F5     -- ������� ���� '#13#10 +
            '  Ctrl-R -- ����������� ���� ������� '#13#10 +
            '  F7     -- ������ ����� '#13#10 +
            '  F8     -- �������� ���������� ������� '#13#10 +
            '  F9     -- ����� ������� '#13#10 +
            '  F11    -- �������� ������� '#13#10 +
            '  F12    -- ����������� ������ ���/eng/��� '
  else
    Hint := '����������� ������� F3 -- ��� ������';
end;

function TgsIBLookupComboBox.GetParams: TStrings;
begin
  if FParams = nil then
    FParams := TStringList.Create;
  Result := FParams;
end;

{$IFDEF DEBUG}
procedure TgsIBLookupComboBox.DblClick;
begin
  inherited;

  raise Exception.Create('Test exception');
end;
{$ENDIF}

function TgsIBLookupComboBox.FieldWithAlias(AFieldName: String): String;

  function AddAlias(S: String): String;
  var
    Pref: String;
    I: Integer;
  begin
    if S[1] = '''' then
    begin
      I := Length(S);
      while (I > 0) and (S[I] <> '''') and (S[I] <> '|') do
        Dec(I);
      Pref := Copy(S, 1, I);
      S := Copy(S, I + 1, 255);
    end else
      Pref := '';

    if (S > '') and (Pos('.', S) = 0) and (Pos('(', S) = 0) then
      Result := Pref + MainTable + '.' + S
    else
      Result := Pref + S;
  end;

var
  StList: TStringList;
  I: Integer;
begin
  Result := Trim(AFieldName);
  if Result > '' then
  begin
    if Pos(',', Result) = 0 then
      Result := AddAlias(Result)
    else begin
      StList := TStringList.Create;
      try
        ParseFieldsString(Result, StList);
        Result := '';
        for I := 0 to StList.Count - 1 do
        begin
          if I > 0 then
            Result := Result + ',';
          Result := Result + AddAlias(Trim(StList[I]));
        end;
      finally
        StList.Free;
      end;
    end;
  end;
end;

procedure TgsIBLookupComboBox.SetDistinct(const Value: Boolean);
begin
  FDistinct := Value;
end;

function TgsIBLookupComboBox.GetDistinct: Boolean;
begin
  Result := FDistinct;
end;

function TgsIBLookupComboBox.GetFullSearchOnExit: Boolean;
begin
  Result := FFullSearchOnExit;
end;

procedure TgsIBLookupComboBox.SetFullSearchOnExit(const Value: Boolean);
begin
  FFullSearchOnExit := Value;
end;

procedure TgsIBLookupComboBox.ConvertText;
var
  OldSS, OldSL: Integer;
begin
  OldSS := SelStart;
  OldSL := SelLength;
  Text := gd_converttext.ConvertText(Text);
  SelStart := OldSS;
  SelLength := OldSL;
end;
{
var
  Ch: array[0..KL_NAMELENGTH] of Char;
  Kl, I, J, OldSS, OldSL: Integer;
  SFrom, STo, S: String;
begin
  GetKeyboardLayoutName(Ch);
  KL := StrToInt('$' + StrPas(Ch));

  case (KL and $3ff) of
    LANG_BELARUSIAN: SFrom := ArrBel;
    LANG_RUSSIAN: SFrom := ArrRus;
    LANG_ENGLISH: SFrom := ArrEng;
  else
    exit;
  end;

  ActivateKeyBoardLayout(HKL_NEXT, 0);
  GetKeyboardLayoutName(Ch);
  KL := StrToInt('$' + StrPas(Ch));

  case (KL and $3ff) of
    LANG_BELARUSIAN: STo := ArrBel;
    LANG_RUSSIAN: STo := ArrRus;
    LANG_ENGLISH: STo := ArrEng;
  else
    exit;
  end;

  S := Text;
  OldSS := SelStart;
  OldSL := SelLength;
  for I := 1 to Length(S) do
  begin
    J := AnsiPos(S[I], SFrom);
    if J > 0 then
      S[I] := STo[J];
  end;
  Text := S;
  SelStart := OldSS;
  SelLength := OldSL;
end;
}

function TgsIBLookupComboBox.GetIsTree: Boolean;
begin
  case FViewType of
    vtTree: if Assigned(gdClass) and (not gdClass.InheritsFrom(TgdcTree)) then
        raise Exception.Create('����� �� ���������� �� ������! �� �� ������ ���������� ��� � ���� ������!')
      else
        Result := True;
    vtGrid: Result := False;
  else
    Result := (gdClass <> nil)
      and gdClass.InheritsFrom(TgdcTree)
      and (not CgdcTree(gdClass).HasLeafs)
      and (
        (AnsiCompareText(StripSpaces(Condition), GetRestrCondition) = 0)
        {or
        (AnsiCompareText(
          StripSpaces(StringReplace(Condition, FListTable + '.', '', [rfIgnoreCase, rfReplaceAll])),
          GetRestrCondition) = 0)}
      );
  end;
end;

function TgsIBLookupComboBox.GetRestrCondition: String;
var
  I: Integer;
begin
  if gdClass <> nil then
  begin
    I := Pos(' ', FListTable)  - 1;
    if I = -1 then I := Length(FListTable);
    Result := gdClass.GetRestrictCondition(Copy(FListTable, 1, I), FSubType);
    { TODO : � ���� � ���� ������ ����� ����� � ��� ������� ����� �����? }
    Result := StringReplace(Result, FgdClass.GetListTableAlias + '.', Copy(FListTable, 1, I) + '.', [rfReplaceAll, rfIgnoreCase]);
    Result := StripSpaces(Result);
  end else
    Result := '';
end;

function TgsIBLookupComboBox.StripSpaces(const S: String): String;
var
  I: Integer;
  Quotas, FirstChar: Boolean;
begin
  Quotas := False;
  FirstChar := True;
  Result := '';
  for I := 1 to Length(S) do
  begin
    case S[I] of
      #0..#32:
      begin
        if not Quotas then
        begin
          if not FirstChar then
          begin
            continue;
          end else
            FirstChar := False;
        end;
      end;

      '"':
      begin
        Quotas := not Quotas;
        FirstChar := True;
      end;
    else
      FirstChar := True;
    end;
    Result := Result + S[I];
  end;
  Result := Trim(Result);
end;

procedure TgsIBLookupComboBox.CNKeyDown(var Message: TWMKeyDown);
begin
  with Message do
  begin
    if Assigned(Database)
      and Database.Connected
      and (not (csDesigning in ComponentState))
      {and (KeyDataToShiftState(KeyData) = [])} then
    begin
      if ReadOnly or (not FDataLink.CanModify) then
      begin
        if KeyDataToShiftState(KeyData) = [] then
        begin
          case CharCode of
            VK_F4, VK_F11:
            begin
              case CharCode of
                VK_F4: Edit;
                VK_F11: ObjectProperties;
              end;
              Result := 1;
              exit;
            end;
          end;
        end;
      end
      else
      begin
        if KeyDataToShiftState(KeyData) = [] then
        begin
          case CharCode of
            VK_F2, VK_F3, VK_F4, {VK_F6,} VK_F7, VK_F8, VK_F9, VK_F11, VK_F12, VK_DOWN:
              begin
                case CharCode of
                  VK_F2: CreateNew(gdcFullClass(nil, ''));
                  VK_F3: DoLookup(False, True, False);
                  VK_F4: Edit;
                  //VK_F6: Reduce;
                  VK_F7: DoLookup(True, True, False);
                  VK_F8: Delete;
                  VK_F9: ViewForm;
                  VK_F11: ObjectProperties;
                  VK_F12: ConvertText;
                  VK_DOWN: DropDown;
                end;
                Result := 1;
                exit;
              end;
          end;
        end
        else if KeyDataToShiftState(KeyData) = [ssCtrl] then
        begin
          if CharCode = Ord('R') then
          begin
            Result := 1;
            Reduce;
            exit;
          end;
        end
        {else if KeyDataToShiftState(KeyData) = [ssAlt] then
        begin
          if CharCode = VK_DOWN then
          begin
            DropDown;
            Result := 1;
            exit;
          end;
        end;}
      end;
    end;
  end;

  inherited;
end;

procedure TgsIBLookupComboBox.CMGetDataLink(var Message: TMessage);
begin
  Message.Result := Integer(FDataLink);
end;

procedure DeleteFromLookupCache(const AKey: String);
var
  P: PChar;
begin
  if FCachedKey.Has(AKey) then
  begin
    P := FCachedKey.Remove(AKey);
    FreeMem(P);
  end;
end;

procedure ClearLookupCache;
begin
  FCachedKey.Iterate(nil, Iterate_FreeMem);
end;

// ��������� ������ FListTable � ���������� ����� ��� ���������
// ������� ��� ��� ������� (���� ����� �� �����) ���
// ������ ������, ���� ����� ������� ��� � ������
function TgsIBLookupComboBox.GetTableAlias(
  const ATableName: String): String;
const
  SacredWords = ';JOIN;LEFT;RIGHT;FULL;OUTER;INNER;,;ON;';
var
  I: Integer;
begin
  I := StrIPos(ATableName, FListTable);
  if I = 0 then
    Result := ''
  else
  begin
    Result := Trim(Copy(FListTable, I + Length(ATableName), 128)); // �����, � ������� ���������� ����� ����� ������� ����� ���������
    if Result > '' then
    begin
      I := Pos(' ', Result);
      if I > 0 then
      begin
        Result := Copy(Result, 1, I - 1);
      end;
      if Pos(';' + UpperCase(Result) + ';', SacredWords) > 0 then
      begin
        Result := ATableName;
      end;
    end else
      Result := ATableName;
  end;
end;

procedure TgsIBLookupComboBox.SetDisplayText(const AText: String; const AParent: Integer = 0);
var
  S, TempS: String;
  I: Integer;
  DC: HDC;
  P: TSize;
  OldF: THandle;
begin
  if (FCurrentKey > '')
    and IsTree
    and Assigned(gdClass)
    and (GetTableAlias(gdClass.GetListTable(FSubType)) > '')
    and (AParent > 0)
    and (Width > MIN_WIDTH_FOR_TREE) then
  begin
    S := AText;

    if (Transaction = nil) or (not Transaction.InTransaction) then
      Fibsql.Transaction := gdcBaseManager.ReadTransaction
    else
      Fibsql.Transaction := Transaction;

    Fibsql.Close;
    Fibsql.SQL.Text := Format('SELECT %s, %s.%s FROM %s WHERE %s = :V ',
      [FieldWithAlias(FListField),
       GetTableAlias(gdClass.GetListTable(FSubType)),
       CgdcTree(gdClass).GetParentField(SubType),
       FListTable,
       FieldWithAlias(FKeyField)]);

    Fibsql.ParamByName('V').AsInteger := AParent;
    repeat
      Fibsql.ExecQuery;
      if not Fibsql.EOF then
      begin
        if S = '' then
        begin
          S := Fibsql.Fields[0].AsString;
        end else
        begin
          TempS := Fibsql.Fields[0].AsString + TreeDelimiter + S;
          DC := GetDC(0);
          OldF := SelectObject(DC, Font.Handle);
          try
            GetTextExtentPoint(DC, @TempS[1], Length(TempS), P);
            if P.cx > Width - 16 then
            begin
              TempS := '...' + TreeDelimiter + S;
              GetTextExtentPoint(DC, @TempS[1], Length(TempS), P);
              if P.cx <= Width - 16 then
                S := TempS;
              break;
            end;
          finally
            SelectObject(DC, OldF);
            ReleaseDC(0, DC);
          end;
          S := TempS;
        end;
        if Fibsql.Fields[1].IsNull then
          break;
        I := Fibsql.Fields[1].AsInteger;
        Fibsql.Close;
        Fibsql.ParamByName('V').AsInteger := I;
      end else
        break;
    until False;
    Fibsql.Close;

    Items[0] := S;
  end else
    Items[0] := AText;
  ItemIndex := 0;
end;

procedure TgsIBLookupComboBox.SetBounds(ALeft, ATop, AWidth,
  AHeight: Integer);
var
  I: Integer;
  DC: HDC;
  OldF: THandle;
  P: TSize;
  TempS: String;
begin
  inherited;

  if IsTree and (CurrentKey > '') then
  begin
    DC := GetDC(0);
    OldF := SelectObject(DC, Font.Handle);
    try
      TempS := Text;
      GetTextExtentPoint(DC, @TempS[1], Length(TempS), P);
      if P.cx > Width - 16 then
      begin
        I := Length(Text) - 1;
        while I > 1 do
        begin
          if Text[I] = TreeDelimiterChar then
          begin
            Text := Copy(Text, I + 1, 1024);
            break;
          end;
          Dec(I);
        end;
      end;
    finally
      SelectObject(DC, OldF);
      ReleaseDC(0, DC);
    end;
  end;
end;

procedure TgsIBLookupComboBox.ParseFieldsString(const AFields: String;
  SL: TStrings);
var
  I, B: Integer;
begin
  I := 1;
  B := 1;
  while I < Length(AFields) do
  begin
    if AFields[I] = '''' then
    begin
      repeat
        Inc(I);
      until (I >= Length(AFields)) or (AFields[I] = '''');
    end
    else if AFields[I] = ',' then
    begin
      SL.Add(Copy(AFields, B, I - B));
      B := I + 1;
    end;
    Inc(I);
  end;
  if B <= Length(AFields) then
    SL.Add(Copy(AFields, B, 255));
end;

function TgsIBLookupComboBox.ConvertDate(const S: String): String;
var
  Y, M, D: Integer;
  YF, MF, DF: Boolean;
  B, E: Integer;
begin
  Result := S;
  if Pos(DateSeparator, S) > 0 then
  begin
    Y := -1; YF := False;
    M := -1; MF := False;
    D := -1; DF := False;
    E := Length(S);
    B := E - 1;
    while B >= 1 do
    begin
      if (S[B] = '.') or (B = 1) then
      begin
        if B = 1 then
          B := 0;
        if not YF then
        begin
          Y := StrToIntDef(Copy(S, B + 1, E - B), -1);
          YF := True;
        end else
        if not MF then
        begin
          M := StrToIntDef(Copy(S, B + 1, E - B), -1);
          MF := True;
        end else
        if not DF then
        begin
          D := StrToIntDef(Copy(S, B + 1, E - B), -1);
          DF := True;
        end else
          exit;

        E := B - 1;
        B := E;
      end else
        Dec(B);
    end;

    if (Y > 1918) and (Y < 3000) then
      Result := IntToStr(Y) + '-'
    else
      exit;

    if (M > 0) and (M < 10) then
      Result := Result + '0' + IntToStr(M) + '-'
    else if (M > 9) and (M < 13) then
      Result := Result + IntToStr(M) + '-'
    else
      exit;

    if (D > 0) and (D < 10) then
      Result := Result + '0' + IntToStr(D)
    else if (D > 9) and (D < 32) then
      Result := Result + IntToStr(D);
  end;
end;

{ TgsIBLCBDataLink }

procedure TgsIBLCBDataLink.ActiveChanged;
begin
  inherited;
  (Control as TgsIBLookupComboBox).SyncWithDataSource;
end;

constructor TgsIBLCBDataLink.Create(ALookupComboBox: TgsIBLookupComboBox);
begin
  inherited Create;
  Control := ALookupComboBox;
  FFirstUse := True;
  FCurrentValue := '';
end;

function TgsIBLCBDataLink.Edit: Boolean;
begin
  if CanModify then
    Result := inherited Edit
  else
    Result := False;
end;

function TgsIBLCBDataLink.GetCanModify: Boolean;
begin
  Result := not ReadOnly;
end;

procedure TgsIBLCBDataLink.RecordChanged(F: TField);
begin
  inherited;
  if Active and ((Control as TgsIBLookupComboBox).DataField > '') then
  begin
    if (FFirstUse
      or (DataSet.FieldByName((Control as TgsIBLookupComboBox).DataField).AsString <> FCurrentValue))
      and
      ((F = nil) or (AnsiCompareText(F.FieldName, (Control as TgsIBLookupComboBox).DataField) = 0)) then
    begin
      FCurrentValue := DataSet.FieldByName((Control as TgsIBLookupComboBox).DataField).AsString;
      FFirstUse := False;
      (Control as TgsIBLookupComboBox).SyncWithDataSource;
    end;
  end;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsIBLookupComboBox]);
end;

initialization
  FCachedKey := TStringHashMap.Create(CaseInsensitiveTraits, 256);

finalization
  {$IFDEF DEBUG}
  OutputDebugString(PChar('������ ���� ������: ' + IntToStr(FCachedKey.Count)));
  {$ENDIF}

  ClearLookupCache;
  FCachedKey.Free;
end.
