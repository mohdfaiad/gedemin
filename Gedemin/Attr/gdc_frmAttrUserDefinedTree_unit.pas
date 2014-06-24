
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_frmAttrUserDefinedTree_unit.pas

  Abstract

    Part of gedemin project.
    View form for user defined tables with tree structure.

  Author

    Denis Romanovski

  Revisions history

    1.0    30.10.2001    Dennis    Initial version.


--}

unit gdc_frmAttrUserDefinedTree_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, IBDatabase, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, ComCtrls, gsDBTreeView, ToolWin, ExtCtrls, TB2Item,
  TB2Dock, TB2Toolbar, IBCustomDataSet, gdcBase, gdcAttrUserDefined,
  gd_MacrosMenu, StdCtrls, gdcTree;

type
  Tgdc_frmAttrUserDefinedTree = class(Tgdc_frmMDVTree)
    Master: TgdcAttrUserDefinedTree;
    Detail: TgdcAttrUserDefinedTree;

    procedure FormCreate(Sender: TObject);

  private

  public
    constructor Create(AnOwner: TComponent); override;
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    class function GetSubTypeList(SubTypeList: TStrings;
      Subtype: string = ''; OnlyDirect: Boolean = False): Boolean; override;
    class function ClassParentSubtype(Subtype: String): String; override;
  end;

var
  gdc_frmAttrUserDefinedTree: Tgdc_frmAttrUserDefinedTree;

implementation

{$R *.DFM}

uses at_classes,  gd_ClassList;

{ Tgdc_frmAttrUserDefinedTree }

constructor Tgdc_frmAttrUserDefinedTree.Create(AnOwner: TComponent);
begin
  inherited;
end;

class function Tgdc_frmAttrUserDefinedTree.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  Result := nil;
end;

procedure Tgdc_frmAttrUserDefinedTree.FormCreate(Sender: TObject);
var
  R: TatRelation;
begin
  gdcObject := Master;
  //gdcObject.SubType := FSubType;

  R := atDatabase.Relations.ByRelationName(FSubType);
  Assert(R <> nil);

  if tvGroup.DisplayField = '' then
    tvGroup.DisplayField := R.ListField.FieldName;

  gdcDetailObject := Detail;
  gdcDetailObject.SubType := FSubType;
  gdcDetailObject.SubSet := 'ByParent';

  if tvGroup.DisplayField = '' then
    tvGroup.DisplayField := gdcObject.GetListField(gdcObject.SubType);

  inherited;

//  gdcObject.Open;
//  gdcDetailObject.Open;

  with atDatabase.Relations do
    if ByRelationName(FSubType) <> nil then
      Self.Caption := ByRelationName(FSubType).LName
    else
      Self.Caption := '������ �� ���������!';

end;

class function Tgdc_frmAttrUserDefinedTree.GetSubTypeList(
  SubTypeList: TStrings; Subtype: string = ''; OnlyDirect: Boolean = False): Boolean;
begin
  Result := TgdcAttrUserDefinedTree.GetSubTypeList(SubTypeList, Subtype, OnlyDirect);
end;

class function Tgdc_frmAttrUserDefinedTree.ClassParentSubtype(
  Subtype: String): String;
begin
  Result := TgdcAttrUserDefinedTree.ClassParentSubtype(SubType);
end;

initialization
  RegisterFrmClass(Tgdc_frmAttrUserDefinedTree);

finalization
  UnRegisterFrmClass(Tgdc_frmAttrUserDefinedTree);

end.

