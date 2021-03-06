unit gdc_attr_dlgStoredProc_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  gdc_dlgGMetaData_unit, Db, ActnList, StdCtrls, ComCtrls, DBCtrls, Mask, ExtCtrls,
  SynEdit, SynMemo, SynEditHighlighter, SynHighlighterSQL, at_Classes, IBSQL,
  IBDatabase, Menus, gdc_dlgG_unit, TB2Item, TB2Dock, TB2Toolbar,
  gsSearchReplaceHelper;

type
  Tgdc_attr_dlgStoredProc = class(Tgdc_dlgGMetaData)
    SynSQLSyn: TSynSQLSyn;
    IBTransaction: TIBTransaction;
    actSearch: TAction;
    actReplace: TAction;
    actSearchNext: TAction;
    actPrepare: TAction;
    pnlBack: TPanel;
    pcStoredProc: TPageControl;
    tsNameSP: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    dbedProcedureName: TDBEdit;
    dbmDescription: TDBMemo;
    tsBodySP: TTabSheet;
    tbdText: TTBDock;
    tbtText: TTBToolbar;
    tbiSearch: TTBItem;
    tbiReplace: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem1: TTBItem;
    smProcedureBody: TSynMemo;
    procedure pcStoredProcChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure actOkUpdate(Sender: TObject);
    procedure dbedProcedureNameEnter(Sender: TObject);
    procedure dbedProcedureNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbedProcedureNameKeyPress(Sender: TObject; var Key: Char);
    procedure pcStoredProcChange(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure actSearchUpdate(Sender: TObject);
    procedure actSearchNextExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure actPrepareExecute(Sender: TObject);
    procedure smProcedureBodySpecialLineColors(Sender: TObject;
      Line: Integer; var Special: Boolean; var FG, BG: TColor);
    procedure smProcedureBodyChange(Sender: TObject);
  private
    FSearchReplaceHelper: TgsSearchReplaceHelper;
  protected
    procedure BeforePost; override;
    procedure InvalidateForm; override;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function TestCorrect: Boolean; override;
    procedure SetupDialog; override;
    procedure SetupRecord; override;
  end;

var
  gdc_attr_dlgStoredProc: Tgdc_attr_dlgStoredProc;

implementation

{$R *.DFM}

uses
  gdcBase,
  gdcMetaData,
  gd_ClassList
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , ib;

{ Tgdc_attr_dlgStoredProc }

procedure Tgdc_attr_dlgStoredProc.pcStoredProcChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  if pcStoredProc.ActivePage = tsNameSP then
  begin
    dbmDescription.SetFocus;
    AllowChange := Trim(gdcObject.FieldByName('procedurename').AsString) > '';

    if AllowChange then
    begin
      if (Pos(UserPrefix, gdcObject.FieldByName('procedurename').AsString) = 0)
        and (gdcObject.State = dsInsert) then
      begin
        gdcObject.FieldByName('procedurename').AsString := UserPrefix +
          gdcObject.FieldByName('procedurename').AsString;
      end;
    end else
    begin
      MessageBox(Handle,
        '���������� ������ ������������ ���������.',
        '��������',
        mb_Ok or mb_IconInformation or MB_TASKMODAL);
      dbedProcedureName.SetFocus;
    end;
  end;
end;

function Tgdc_attr_dlgStoredProc.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  ibsql: TIBSQL;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_ATTR_DLGSTOREDPROC', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_ATTR_DLGSTOREDPROC', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ATTR_DLGSTOREDPROC') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ATTR_DLGSTOREDPROC',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_ATTR_DLGSTOREDPROC' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  
  ClearError;
  if gdcObject.FieldByName('procedurename').AsString = '' then
    raise EgdcIBError.Create('���������� ������� ��� ���������');

  if (smProcedureBody.Text > '') and
     (Pos(UpperCase(Trim(gdcObject.FieldByName('procedurename').AsString)), UpperCase(smProcedureBody.Text)) = 0) then
  begin
    raise EgdcIBError.Create('������������ ��� �������');
  end;

  Result := False;

  if gdcObject.FieldByName('rdb$procedure_source').AsString > '' then
  begin
    ibsql := TIBSQL.Create(nil);
    IBTransaction.StartTransaction;
    try
      ibsql.Transaction := IBTransaction;
      ibsql.SQL.Text := gdcObject.FieldByName('rdb$procedure_source').AsString;
      ibsql.ParamCheck := False;
      try
        ibsql.Prepare;
        ibsql.CheckValidStatement;
      except
        on E: Exception do
        begin
          ExtractErrorLine(E.Message);
          raise EgdcIBError.Create(Format('��� ���������� ��������� �������� ��������� ������: %s',
            [E.Message]));
        end;
      end;
    finally
      ibsql.Free;
      IBTransaction.RollBack;
    end;
    Result := True;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ATTR_DLGSTOREDPROC', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ATTR_DLGSTOREDPROC', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_attr_dlgStoredProc.actOkUpdate(Sender: TObject);
begin
  if Trim(smProcedureBody.Text) > '' then
    inherited
  else
    actOk.Enabled := False;  
  btnOK.Default := not smProcedureBody.Focused;
end;

procedure Tgdc_attr_dlgStoredProc.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_ATTR_DLGSTOREDPROC', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_ATTR_DLGSTOREDPROC', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ATTR_DLGSTOREDPROC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ATTR_DLGSTOREDPROC',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_ATTR_DLGSTOREDPROC' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  gdcObject.FieldByName('rdb$procedure_source').AsString := smProcedureBody.Text;

  if (Trim(dbmDescription.Lines.Text) = '') and (gdcObject.FieldByName('RDB$DESCRIPTION').AsString <> ' ') then
    gdcObject.FieldByName('RDB$DESCRIPTION').AsString:= ' ';

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ATTR_DLGSTOREDPROC', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ATTR_DLGSTOREDPROC', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_attr_dlgStoredProc.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_ATTR_DLGSTOREDPROC', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_ATTR_DLGSTOREDPROC', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ATTR_DLGSTOREDPROC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ATTR_DLGSTOREDPROC',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_ATTR_DLGSTOREDPROC' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if gdcObject.State = dsEdit then
  begin
    dbedProcedureName.Enabled := False;
    smProcedureBody.Text := (gdcObject as TgdcStoredProc).GetProcedureText
  end
  else if (sCopy in gdcObject.BaseState) and (gdcObject.State = dsInsert) then
  begin
    smProcedureBody.Text := (gdcObject as TgdcStoredProc).GetProcedureText;
  end
  else
    smProcedureBody.Text := '';

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ATTR_DLGSTOREDPROC', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ATTR_DLGSTOREDPROC', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_attr_dlgStoredProc.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_ATTR_DLGSTOREDPROC', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_ATTR_DLGSTOREDPROC', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ATTR_DLGSTOREDPROC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ATTR_DLGSTOREDPROC',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_ATTR_DLGSTOREDPROC' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  pcStoredProc.ActivePage := tsNameSP;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ATTR_DLGSTOREDPROC', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ATTR_DLGSTOREDPROC', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_attr_dlgStoredProc.dbedProcedureNameEnter(Sender: TObject);
var
  S: string;
begin
  S:= '00000409';
  LoadKeyboardLayout(@S[1], KLF_ACTIVATE);
end;

procedure Tgdc_attr_dlgStoredProc.dbedProcedureNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if ((Shift = [ssShift]) and (Key = VK_INSERT)) or ((Shift = [ssCtrl]) and (Chr(Key) in ['V', 'v'])) then begin
    CheckClipboardForName;
  end;
end;

procedure Tgdc_attr_dlgStoredProc.dbedProcedureNameKeyPress(
  Sender: TObject; var Key: Char);
begin
  Key:= CheckNameChar(Key);
end;

procedure Tgdc_attr_dlgStoredProc.pcStoredProcChange(Sender: TObject);
begin
  if pcStoredProc.ActivePage = tsBodySP then
  begin
    if smProcedureBody.Text = '' then
      smProcedureBody.Text := (gdcObject as TgdcStoredProc).GetProcedureText;
  end;
end;

constructor Tgdc_attr_dlgStoredProc.Create(AnOwner: TComponent);
begin
  inherited;
  FEnterAsTab := 2; // �������� EnterAsTab
  // ��������������� ������ ��� ������ �� ���� �����
  FSearchReplaceHelper := TgsSearchReplaceHelper.Create(smProcedureBody);
end;

destructor Tgdc_attr_dlgStoredProc.Destroy;
begin
  FreeAndNil(FSearchReplaceHelper);
  inherited;
end;

procedure Tgdc_attr_dlgStoredProc.actSearchExecute(Sender: TObject);
begin
  FSearchReplaceHelper.Search;
end;

procedure Tgdc_attr_dlgStoredProc.actReplaceExecute(Sender: TObject);
begin
  FSearchReplaceHelper.Replace;
end;

procedure Tgdc_attr_dlgStoredProc.actSearchUpdate(Sender: TObject);
begin
  actSearch.Enabled := smProcedureBody.Lines.Count > 0;
  actSearchNext.Enabled := actSearch.Enabled;
  actReplace.Enabled := actSearch.Enabled;
end;

procedure Tgdc_attr_dlgStoredProc.actSearchNextExecute(Sender: TObject);
begin
  FSearchReplaceHelper.SearchNext;
end;

procedure Tgdc_attr_dlgStoredProc.actPrepareExecute(Sender: TObject);
var
  ibsqlTest: TIBSQL;
  TestTransaction: TIBTransaction;
begin
  ClearError;
  ibsqlTest := TIBSQL.Create(nil);
  TestTransaction := TIBTransaction.Create(nil);
  try
    TestTransaction.DefaultDatabase := gdcObject.Database;
    TestTransaction.StartTransaction;
    try
      ibsqlTest.Transaction := TestTransaction;
      ibsqlTest.SQL.Text := smProcedureBody.Text;
      ibsqlTest.ParamCheck := False;
      try
        ibsqlTest.Prepare;
      except 
        on E: Exception do
        begin
          ExtractErrorLine(E.Message);
          MessageBox(Self.Handle, PChar(E.Message), '',
            MB_OK or MB_ICONWARNING or MB_TASKMODAL);
        end;
      end;
    finally
      TestTransaction.Rollback;
    end;
  finally
    FreeAndNil(TestTransaction);
    FreeAndNil(ibsqlTest);
  end;
end;

procedure Tgdc_attr_dlgStoredProc.InvalidateForm;
begin
  smProcedureBody.Invalidate;
end;

procedure Tgdc_attr_dlgStoredProc.smProcedureBodySpecialLineColors(
  Sender: TObject; Line: Integer; var Special: Boolean; var FG,
  BG: TColor);
begin
  if Line = FErrorLine then
  begin
    Special := True;
    BG := clRed;
    FG := clWhite;
  end;  
end;

procedure Tgdc_attr_dlgStoredProc.smProcedureBodyChange(Sender: TObject);
begin
  ClearError;
end;

initialization
  RegisterFrmClass(Tgdc_attr_dlgStoredProc);

finalization
  UnRegisterFrmClass(Tgdc_attr_dlgStoredProc);

end.
