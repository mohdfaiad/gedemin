
{********************************************************}
{                                                        }
{       InterBase User Defined Fuctions                  }
{       GUDF library                                     }
{       Copyright (c) 1999-2000 by Golden Software       }
{                                                        }
{       Thanks:                                          }
{         Oleg Kukarthev                                 }
{                                                        }
{********************************************************}

//  21.03.2002 Nick ��������� �������� ����������  g_m_complround

{$ALIGN OFF}

unit GUDFlib;

interface

uses
  SysUtils, Classes;

type
// C, C++     Delphi          InterBase
  Short     = SmallInt;    // SmallInt
  Long      = Longint;     // Integer
  // int    = Integer;     // Integer
  Float     = Single;      // Float
  // Double = Double;      // Double
  // *void, *AnsiChar = PAnsiChar; // AnsiChar(???), VarChar(???), CString

  PSmallInt = ^SmallInt;
  PInteger  = ^Integer;
  PShort    = ^Short;
  PLong     = ^Long;
  PFloat    = ^Float;
  PDouble   = ^Double;

  TBLOb = record
    GetSegment : function(Handle : Pointer; Buffer : PAnsiChar;
     MaxLength : Long; var ReadLength : Long) : WordBool; cdecl;
    Handle : Pointer;               // BLOb handle
    SegCount,                       // Number of BLOb segments
    MaxSegLength,                   // Max length of BLOb segment
    TotalLength : Long;             // Total BLOb length
    PutSegment : procedure(Handle : Pointer; Buffer : PAnsiChar;
      Length : Long); cdecl;
    // Seek : function : Long; cdecl; // I don'n know input parameters
  end;

type
  PIBDateTime = ^TIBDateTime;
  TIBDateTime = record
    Days,                           // Date: Days since 17 November 1858
    MSec10 : Integer;               // Time: Millisecond * 10 since midnigth
  end;

const                               // Date translation constants
  MSecsPerDay10 = MSecsPerDay * 10; // Milliseconds per day * 10
  IBDateDelta = 15018;              // Days between Delphi and InterBase dates

  MaxBLObPutLength = 80;

function g_sec_test(var AccessSet, UserRights: Integer): Integer;
  cdecl; export;
function g_sec_testall(var AFull, AChag, AView, UserRights: Integer): Integer;
  cdecl; export;
function g_b_and(var A, B: Integer): Integer;
  cdecl; export;
function g_b_or(var A, B: Integer): Integer;
  cdecl; export;
function g_b_xor(var A, B: Integer): Integer;
  cdecl; export;
function g_b_shl(var A, B: Integer): Integer;
  cdecl; export;
function g_b_shr(var A, B: Integer): Integer;
  cdecl; export;
function g_b_not(var A: Integer): Integer;
  cdecl; export;
function g_b_andex(var A, B, C, D: Integer): Integer;
  cdecl; export;
function g_m_random(var iLong: Integer): Integer;
  cdecl; export;
function g_d_encodedate(var Year, Month, Day: SmallInt;
  var IBDateTime: TIBDateTime): PIBDateTime; cdecl; export;
function g_d_year(var IBDateTime: TIBDateTime): Word;
  cdecl; export;
function g_d_quarter(var IBDateTime: TIBDateTime): Word; cdecl; export;
function g_d_month(var IBDateTime: TIBDateTime): Word; cdecl; export;
function g_d_inchours(var IncHours: Integer; var IBDateTime: TIBDateTime): PIBDateTime; cdecl; export;
function g_d_incmonth(var IncMonthes: Integer; var IBDateTime: TIBDateTime): PIBDateTime; cdecl; export;
function g_d_getdateparam(var IBDateTime: TIBDateTime;
  var DateParam: Integer): Integer; cdecl; export;
function g_d_gettimeparam(var AnIBDateTime: TIBDateTime;
  var ATimeParam: Integer): Integer; cdecl; export;
function g_d_getdayofweek(var IBDateTime: TIBDateTime): Integer;
  cdecl; export;
function g_d_date2int(var IBDateTime: TIBDateTime): Integer;
  cdecl; export;
function g_d_workdaysbetween(var IBDateTimeA: TIBDateTime; var IBDateTimeB: TIBDateTime): Integer;
  cdecl; export;
function g_d_date2str(var IBDateTime: TIBDateTime): PAnsiChar;
  cdecl; export;
function g_d_date2str_ymd(var IBDateTime: TIBDateTime): PAnsiChar;
  cdecl; export;
function g_d_formatdatetime(F: PAnsiChar; var IBDateTime: TIBDateTime): PAnsiChar;
  cdecl; export;
function g_s_float2str(var D: Double): PAnsiChar;
  cdecl; export;
function g_m_round(var D: Double): Integer;
  cdecl; export;
function g_m_roundnn(var D, Digit: Double): Double;
  cdecl; export;
function g_m_complround(var D: Double; var Limit: Integer; var LoRound, HiRound: Double): Double;
  cdecl; export;
function g_d_monthname(var M: SmallInt): PAnsiChar;
  cdecl; export;
function g_s_boolean2str(var B: SmallInt): PAnsiChar;
  cdecl; export;
function g_s_ansicomparetext(A, B: PAnsiChar): SmallInt;
  cdecl; export;
function g_s_ansiuppercase(CString: PAnsiChar): PAnsiChar;
  cdecl; export;
function g_s_comparename(A, B: PAnsiChar): SmallInt;
  cdecl; export;
function g_s_ansilowercase(CString: PAnsiChar): PAnsiChar;
  cdecl; export;
function g_s_ansipos(A, B: PAnsiChar): SmallInt;
  cdecl; export;
function g_s_fuzzymatch(var MaxMatching: Integer; A, B: PAnsiChar): Integer;
  cdecl; export;
function g_s_ansiposreg(A, B: PAnsiChar; var R: SmallInt): SmallInt;
  cdecl; export;
function g_s_pos(A, B: PAnsiChar): SmallInt;
  cdecl; export;
function g_s_copy(A: PAnsiChar; var Index, Count: SmallInt): PAnsiChar;
  cdecl; export;
function g_s_trim(A: PAnsiChar; B: PAnsiChar): PAnsiChar;
  cdecl; export;
function g_s_ternary(var F: SmallInt; A: PAnsiChar; B: PAnsiChar): PAnsiChar;
  cdecl; export;
function g_s_like(A: PAnsiChar; B: PAnsiChar): SmallInt;
  cdecl; export;
function g_s_length(A: PAnsiChar): SmallInt;
  cdecl; export;
function g_s_delete(A: PAnsiChar; var Index: SmallInt; var Len: SmallInt): PAnsiChar;
  cdecl; export;
function g_s_delchar(A: PAnsiChar): Integer;
  cdecl; export;
function g_d_serverdate: PIBDateTime;
  cdecl; export;
function g_ais_getitemscount(A: PAnsiChar): SmallInt;
  cdecl; export;
function g_ais_getitembyindex(A: PAnsiChar; var Index: SmallInt): Integer;
  cdecl; export;
function g_ais_inarray(A: PAnsiChar; var I: Integer): SmallInt;
  cdecl; export;
procedure g_blob_info(var BLOb: TBLOb; CString: PAnsiChar); cdecl; export;
function g_blob_size(var BLOb: TBLOb): Integer; cdecl; export;
function g_blob_search(var BLOb : TBLOb; KeyWord : PAnsiChar) : Integer; cdecl; export;
procedure g_blob_blobtocstring(var BLOb: TBLOb; CString: PAnsiChar); cdecl; export;
procedure g_blob_cstringtoblob(CString: PAnsiChar; var BLOb: TBLOb); cdecl; export;
function g_his_create: Integer;
  cdecl; export;
function g_his_exclude(var AnIndex: Integer; var AnElement: Integer): Integer;
  cdecl; export;
function g_his_include(var AnIndex: Integer; var AnElement: Integer): Integer;
  cdecl; export;
function g_his_has(var AnIndex: Integer; var AnElement: Integer): Integer;
  cdecl; export;
function g_his_destroy(var AnIndex: Integer): Integer;
  cdecl; export;

implementation

uses
  FindCompare, gsHugeIntSet, syncobjs;

const
  SmallNumber        = 0.0001;
  HugeIntSetMaxCount = 4;

var
  arrHugeIntSet: array[0..HugeIntSetMaxCount - 1] of TgsHugeIntSet;
  csHugeIntSet: TCriticalSection;

(*

  g_sec_test

  � ������� ���������� ���������� ������������ (������� ����� �����,
  ���������� ������ �� ���-����) � ����� �����, � ������� ������
  ������������ (��� ������-�� ���������� ����� ������������).

  ������� ���������� ������, ���� ���������� �� ������ �����������.

  ��� ������������, ������� ������ � ������ �������������� ������� ������
  ������ ������.

*)

function g_sec_test(var AccessSet, UserRights: Integer): Integer;
  cdecl; export;
begin
  Result := (UserRights and (AccessSet or 1));
end;

(*

  g_sec_testall

  � ������� ���������� ��� ����������� ������������ �� ������� ������
  � ����� �����, � ������� ������ ������������.

  ������� ���������� ������, ���� ���������� �������� ����������� �����
  �������� � ������� ������ ������������ � ������������ �����, ��������
  ����� ����� ������������ ������������.

  ������� �����������, ���� ���� ���������� ���������� �� �����-������
  ����� � ������������ ��� ���.

  ���� ������������ ������ � ������ ��������������, �� ������� ������
  ������.

*)
function g_sec_testall(var AFull, AChag, AView, UserRights: Integer): Integer;
  cdecl; export;
begin
  Result := ((AFull or AChag or AView or 1) and UserRights);
end;

function g_b_and(var A, B: Integer): Integer;
  cdecl; export;
begin
  Result := A and B;
end;

function g_b_or(var A, B: Integer): Integer;
  cdecl; export;
begin
  Result := A or B;
end;

function g_b_xor(var A, B: Integer): Integer;
  cdecl; export;
begin
  Result := A xor B;
end;

function g_b_shl(var A, B: Integer): Integer;
  cdecl; export;
begin
  Result := A shl B;
end;

function g_b_shr(var A, B: Integer): Integer;
  cdecl; export;
begin
  Result := A shr B;
end;

function g_b_not(var A: Integer): Integer;
  cdecl; export;
begin
  Result := not A;
end;

function g_b_andex(var A, B, C, D: Integer): Integer;
  cdecl; export;
begin
  Result := (A or B or C) and D;
end;

// ==============================================
//  declare external function ...
//    integer
//  returns
//    integer by value
//  ...
// ==============================================

function g_m_random(var iLong: Integer): Integer;
  cdecl; export;
begin
  Result := Random(iLong);
end;

//  D A T E    F U N C T I O N S

// ==============================================
//  declare external function ...
//    smallint, smallint, smallint, date
//  returns
//    date
//  ...
// ==============================================

function g_d_encodedate(var Year, Month, Day: SmallInt;
  var IBDateTime: TIBDateTime): PIBDateTime; cdecl; export;
var
  DateTime: TDateTime;
  DelphiDays : Integer;
begin
  DateTime := EncodeDate(Year, Month, Day);
  DelphiDays := Trunc(DateTime);
  with IBDateTime do begin
    Days := DelphiDays + IBDateDelta;
    MSec10 := Trunc((DateTime - DelphiDays) * MSecsPerDay10);
  end;
  Result := @IBDateTime;
end;

function g_d_year(var IBDateTime: TIBDateTime): Word; cdecl; export;
var
  DelphiDays : Double;
  Year, Month, Day: Word;
begin
  DelphiDays := IBDateTime.Days - IBDateDelta;
  DecodeDate(DelphiDays, Year, Month, Day);
  Result := Year;
end;

function g_d_quarter(var IBDateTime: TIBDateTime): Word; cdecl; export;
var
  DelphiDays : Double;
  Year, Month, Day: Word;
begin
  DelphiDays := IBDateTime.Days - IBDateDelta;
  DecodeDate(DelphiDays, Year, Month, Day);
  Result := Month div 4;
end;

function g_d_month(var IBDateTime: TIBDateTime): Word; cdecl; export;
var
  DelphiDays : Double;
  Year, Month, Day: Word;
begin
  DelphiDays := IBDateTime.Days - IBDateDelta;
  DecodeDate(DelphiDays, Year, Month, Day);
  Result := Month;
end;

threadvar
  ThreadResultS: array[0..31] of AnsiChar;


// ==============================================
//  declare external function ...
//    date
//  returns
//    date
//  ...
// ==============================================

function g_d_inchours(var IncHours: Integer; var IBDateTime: TIBDateTime): PIBDateTime; cdecl; export;
var
  DateTime: TDateTime;
  DelphiDays : Integer;
  Stamp: TTimeStamp;
begin
  with IBDateTime do
    DateTime := Days - IBDateDelta + MSec10 / MSecsPerDay10;

  Stamp := DateTimeToTimeStamp(DateTime);

  // ��������� �����
  Inc(Stamp.Date, IncHours div 24);
  Dec(IncHours, (IncHours div 24) * 24);

  // ��������� �����������
  Inc(Stamp.Time, IncHours * 60 * 60 * 1000);
  if Stamp.Time > MSecsPerDay then
  begin
    Inc(Stamp.Date);
    Dec(Stamp.Time, MSecsPerDay);
  end;
  // ������� ����� ����
  DateTime := TimeStampToDateTime(Stamp);

  // ��������� ���� � ������ Interbase
  DelphiDays := Trunc(DateTime);
  with IBDateTime do begin
    Days := DelphiDays + IBDateDelta;
    MSec10 := Trunc((DateTime - DelphiDays) * MSecsPerDay10);
  end;
  Result := @IBDateTime;
end;


// ==============================================
//  declare external function ...
//    date
//  returns
//    date
//  ...
// ==============================================

function g_d_incmonth(var IncMonthes: Integer; var IBDateTime: TIBDateTime): PIBDateTime; cdecl; export;
var
  DateTime: TDateTime;
  DelphiDays : Integer;
begin
  with IBDateTime do
    DateTime := Days - IBDateDelta + MSec10 / MSecsPerDay10;

  DateTime := IncMonth(DateTime, IncMonthes);

  // ��������� ���� � ������ Interbase
  DelphiDays := Trunc(DateTime);
  with IBDateTime do begin
    Days := DelphiDays + IBDateDelta;
    MSec10 := Trunc((DateTime - DelphiDays) * MSecsPerDay10);
  end;
  Result := @IBDateTime;
end;


// ==============================================
//  declare external function ...
//    date, Integer
//  returns
//    day
//  ...
// ==============================================

(*

we don't need this in IB6.0*)

function g_d_getdateparam(var IBDateTime: TIBDateTime;
  var DateParam: Integer): Integer; cdecl; export;
var
  DateTime: TDateTime;
  Y, M, D: Word;
begin
  with IBDateTime do
    DateTime := Days - IBDateDelta + MSec10 / MSecsPerDay10;

  DecodeDate(DateTime, Y, M, D);

  case DateParam of
    0: Result := D;
    1: Result := M;
    4:
    begin
      case M of
        1..3: Result := 1;
        4..6: Result := 2;
        7..9: Result := 3;
      else
        Result := 4;
      end;
    end; //quarter
  else
    Result := Y;
  end;
end;

// ==============================================
//  declare external function ...
//    date, smallint
//  returns
//    minutes
//  ...
// ==============================================

(*

we don't need this in IB6.0 *)

function g_d_gettimeparam(var AnIBDateTime: TIBDateTime;
  var ATimeParam: Integer): Integer; cdecl; export;
var
  DateTime: TDateTime;
  Hour, Min, Sec, MSec: Word;
begin
  Assert(ATimeParam in [0..3]);

  with AnIBDateTime do
    DateTime := Days - IBDateDelta + MSec10 / MSecsPerDay10;

  DecodeTime(DateTime, Hour, Min, Sec, MSec);
  case ATimeParam of
    0: Result := Hour;
    1: Result := Min;
    2: Result := Sec;
    3: Result := MSec;
  else
    Result := -1;
  end
end;

// ==============================================
//  declare external function ...
//    date
//  returns
//    smallint
//  ...
// ==============================================

function g_d_getdayofweek(var IBDateTime: TIBDateTime): Integer;
  cdecl; export;
var
  DateTime: TDateTime;
begin
  with IBDateTime do
    DateTime := Days - IBDateDelta + MSec10 / MSecsPerDay10;

  Result := DayOfWeek(DateTime);
end;

function g_d_date2int(var IBDateTime: TIBDateTime): Integer;
  cdecl; export;
var
  DateTime: TDateTime;
begin
  with IBDateTime do
    DateTime := Days - IBDateDelta + MSec10 / MSecsPerDay10;

  Result := Trunc(DateTime);
end;

// ==============================================
//  returns number of work days between two dates
//  now, days excluding saturday and sunday
//  both dates are included, so between 1.01.2001
//  and 10.01.2001 are 8 work days.
//
//  declare external function ...
//    timestamp, timestamp
//  returns
//    integer
//  ...
// ==============================================

function g_d_workdaysbetween(var IBDateTimeA: TIBDateTime; var IBDateTimeB: TIBDateTime): Integer;
  cdecl; export;
var
  DateTimeA, DateTimeB: TDateTime;
begin
  with IBDateTimeA do
    DateTimeA := Int(Days - IBDateDelta + MSec10 / MSecsPerDay10);

  with IBDateTimeB do
    DateTimeB := Int(Days - IBDateDelta + MSec10 / MSecsPerDay10);

  Result := 0;
  while DateTimeA <= DateTimeB do
  begin
    if (DayOfWeek(DateTimeA) >= 2) and (DayOfWeek(DateTimeA) <= 6) then
      Inc(Result);
    DateTimeA := DateTimeA + 1;
  end;
end;

// ==============================================
//  declare external function ...
//    date
//  returns
//
//  ...
// ==============================================

threadvar
  ThreadResultDate2Str: array[0..31] of AnsiChar;

function g_d_date2str(var IBDateTime: TIBDateTime): PAnsiChar;
  cdecl; export;
var
  DateTime: TDateTime;
begin
  with IBDateTime do
    DateTime := Days - IBDateDelta + MSec10 / MSecsPerDay10;

  Result := StrPCopy(ThreadResultDate2Str, AnsiString(DateToStr(DateTime)));
end;

threadvar
  ThreadResultDate2Str_ymd: array[0..63] of AnsiChar;

function g_d_date2str_ymd(var IBDateTime: TIBDateTime): PAnsiChar;
  cdecl; export;
var
  DateTime: TDateTime;
begin
  with IBDateTime do
    DateTime := Days - IBDateDelta + MSec10 / MSecsPerDay10;

  Result := StrPCopy(ThreadResultDate2Str_ymd, FormatDateTime('yyyy.mm.dd', DateTime));
end;

threadvar
  ThreadResultFormatDateTime: array[0..63] of AnsiChar;

function g_d_formatdatetime(F: PAnsiChar; var IBDateTime: TIBDateTime): PAnsiChar;
  cdecl; export;
var
  DateTime: TDateTime;
begin
  with IBDateTime do
    DateTime := Days - IBDateDelta + MSec10 / MSecsPerDay10;
  Result := StrPCopy(ThreadResultFormatDateTime, FormatDateTime(F, DateTime));
end;

// ==============================================
//  declare external function ...
//    double precision
//  returns
//    cstring(32)
//  ...
// ==============================================
function g_s_float2str(var D: Double): PAnsiChar;
  cdecl; export;
begin
  Result := StrPCopy(ThreadResultS, FloatToStrF(D, ffNumber, 15, 2));
end;

function g_m_round(var D: Double): Integer;
  cdecl; export;
begin
  if D > 0 then
    Result := Integer(Round(D + SmallNumber))
  else
    Result := Integer(Round(D - SmallNumber));
end;

function g_m_roundnn(var D, Digit: Double): Double;
  cdecl; export;
begin
  if Digit = 0 then
  begin
    Result := Round(D);
  end else
  begin
    if D > 0 then
      Result := Round(D / Digit + SmallNumber) * Digit
    else
      Result := Round(D / Digit - SmallNumber) * Digit;
  end;
end;

// ������� ����������
// ���� D < Limit ��������� do LoRound
// ���� D > Limit ��������� do HiRound

function g_m_complround(var D: Double; var Limit: Integer; var LoRound, HiRound: Double): Double;
  cdecl; export;
begin
  if HiRound = 0 then
    Result := 0
  else
    Result := Trunc((D / HiRound) + 0.499999) * HiRound;
end;

threadvar
  ThreadResultMonthName: array[0..31] of AnsiChar;

function g_d_monthname(var M: SmallInt): PAnsiChar;
  cdecl; export;
const
  MonthNames: array[1..12] of AnsiString = (
    '������',
    '�������',
    '����',
    '������',
    '���',
    '����',
    '����',
    '������',
    '��������',
    '�������',
    '������',
    '�������'
  );
begin
  Result := StrPCopy(ThreadResultMonthName, MonthNames[M]);
end;

threadvar
  ThreadResultBoolean2Str: array[0..3] of AnsiChar;

function g_s_boolean2str(var B: SmallInt): PAnsiChar;
  cdecl; export;
begin
  if B = 0 then
    Result := StrCopy(ThreadResultBoolean2Str, '���')
  else
    Result := StrCopy(ThreadResultBoolean2Str, '��');
end;

function g_s_ansicomparetext(A, B: PAnsiChar): SmallInt;
  cdecl; export;
begin
  Result := AnsiCompareText(A, B);
end;

threadvar
  ThreadResultAnsiUpperCase: array[0..2000] of AnsiChar;

function g_s_ansiuppercase(CString: PAnsiChar): PAnsiChar;
  cdecl; export;
begin
  Result := StrPCopy(ThreadResultAnsiUpperCase, AnsiUpperCase(CString));
end;

function g_s_comparename(A, B: PAnsiChar): SmallInt;
  cdecl; export;
var
  i: Integer;
begin

  Result := 0;
  if StrLen(A) >= StrLen(B) then
  begin
    i := 0;
    while B[i] <> #0 do
    begin
      if ((A[i] = B[i]) or (B[i] = '*')) then
        Result := 1
      else
      begin
        Result := 0;
        Break;
      end;
      Inc(I);
    end;
  end;
end;

threadvar
  ThreadResultAnsiLowerCase: array[0..2000] of AnsiChar;

function g_s_ansilowercase(CString: PAnsiChar): PAnsiChar;
  cdecl; export;
begin
  Result := StrPCopy(ThreadResultAnsiLowerCase, AnsiLowerCase(CString));
end;

function g_s_ansipos(A, B: PAnsiChar): SmallInt;
  cdecl; export;
begin
  Result := Pos(AnsiUpperCase(A), AnsiUpperCase(B));
end;

function g_s_fuzzymatch(var MaxMatching: Integer; A, B: PAnsiChar): Integer;
  cdecl; export;
var
  SA, SB: AnsiString;
begin
  SA := AnsiUpperCase(StrPas(A)) + #0;
  SB := AnsiUpperCase(StrPas(B)) + #0;
  Result := IndistinctMatching(MaxMatching, @SA[1], @SB[1]);
end;

function g_s_ansiposreg(A, B: PAnsiChar; var R: SmallInt): SmallInt;
  cdecl; export;
begin
  if R = 1 then
    Result := Pos(AnsiUpperCase(A), AnsiUpperCase(B))
  else
    Result := AnsiPos(A, B);
end;

function g_s_pos(A, B: PAnsiChar): SmallInt;
  cdecl; export;
begin
  Result := Pos(A, B);
end;

threadvar
  CopyResult: array[0..2000] of AnsiChar;

function g_s_copy(A: PAnsiChar; var Index, Count: SmallInt): PAnsiChar;
  cdecl; export;
var
  S: AnsiString;
begin
  S := StrPas(A);
  S := Copy(S, Index, Count);
  Result := StrPCopy(CopyResult, S);
end;

function _TrimStr(const S, S2: AnsiString): AnsiString;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(S) do
    if Pos(S[I], S2) <= 0 then
      Result := Result + S[I];
end;

threadvar
  TrimResult: array[0..2000] of AnsiChar;

function g_s_trim(A: PAnsiChar; B: PAnsiChar): PAnsiChar;
  cdecl; export;
begin
  Result := StrPCopy(TrimResult, _TrimStr(StrPas(A), StrPas(B)));
end;

function g_s_ternary(var F: SmallInt; A: PAnsiChar; B: PAnsiChar): PAnsiChar;
  cdecl; export;
begin
  if F = 0 then
    Result := B
  else
    Result := A;
end;

function g_s_like(A: PAnsiChar; B: PAnsiChar): SmallInt;
  cdecl; export;
const
  Nonsense = '''"- `_.,;:!=+()*/\|@#��������ި';
  Arr: array[1..34] of AnsiString = (
    '���',
    '���',
    '���',
    '���',
    '��',
    '���',
    '���',
    '���',
    '���',
    '�-�',
    '��.',
    '��',
    '��',
    '�-�',
    '��',
    '�����',
    '��������',
    '����',
    '�����',
    '�������',
    '����������',
    '��',
    '���',
    '���',
    '���������',
    '������',
    '��������',
    '�-��',
    '���',
    '��',
    '�����',
    '����',
    '���',
    '�����������');
var
  First, Second: AnsiString;
  I, J: Integer;
begin
  if StrLen(A) < StrLen(B) then
  begin
    First := StrPas(A);
    Second := StrPas(B);
  end else
  begin
    First := StrPas(B);
    Second := StrPas(A);
  end;

  First := AnsiUpperCase(First);
  Second := AnsiUpperCase(Second);

  if Pos(First, Second) > 0 then
  begin
    Result := 1;
    exit;
  end;

  for I := 1 to 34 do
  begin
    J := Pos(Arr[I], First);
    while J > 0 do
    begin
      Delete(First, J, Length(Arr[I]));
      J := Pos(Arr[I], First);
    end;
  end;

  for I := 1 to 34 do
  begin
    J := Pos(Arr[I], Second);
    while J > 0 do
    begin
      Delete(Second, J, Length(Arr[I]));
      J := Pos(Arr[I], Second);
    end;
  end;

  if Pos(First, Second) > 0 then
  begin
    Result := 1;
    exit;
  end;

  if Length(First) * 2 < Length(Second) then
  begin
    Result := 0;
    exit;
  end;

  First := _TrimStr(First, Nonsense);
  Second := _TrimStr(Second, Nonsense);

  if (Length(First) > 3) and (Pos(First, Second) > 0) then
    Result := 1
  else
    Result := 0;
end;

function g_s_length(A: PAnsiChar): SmallInt;
  cdecl; export;
begin
  Result := StrLen(A);
end;

threadvar
  DeleteResult: array[0..2000] of AnsiChar;

function g_s_delete(A: PAnsiChar; var Index: SmallInt; var Len: SmallInt): PAnsiChar;
  cdecl; export;
var
  S: AnsiString;
begin
  S := StrPas(A);
  Delete(S, Index, Len);
  Result := StrPCopy(DeleteResult, S);
end;

// ������� ������� �� ������
function g_s_delchar(A: PAnsiChar): Integer;
  cdecl; export;
var
  S: array[0..1024] of AnsiChar;
  I, K: Integer;
begin
  Result := 0;
  if (A <> nil) and (A[0] <> #0) then
  begin
    K := 0;
    for I := 0 to StrLen(A) - 1 do
    begin
      if (K < SizeOf(S) - 1) and (A[I] in ['0'..'9']) then
      begin
        S[K] := A[I];
        Inc(K);
      end else
        break;
    end;
    if K > 0 then
    begin
      S[K] := #0;
      Result := StrToIntDef(S, 0);
    end;
  end;
end;


// ==============================================
//  declare external function ...
//
//  returns
//    date
//  ...
// ==============================================
threadvar
  ServerIBDateTime: TIBDateTime;

function g_d_serverdate: PIBDateTime;
  cdecl; export;
var
  DateTime: TDateTime;
  DelphiDays : Integer;
begin
  DateTime := Now;
  DelphiDays := Trunc(DateTime);
  with ServerIBDateTime do begin
    Days := DelphiDays + IBDateDelta;
    MSec10 := Trunc((DateTime - DelphiDays) * MSecsPerDay10);
  end;
  Result := @ServerIBDateTime;
end;

(*

  Array of Integer as AnsiString (AIS)

  added 09-08-99 by andreik

  ��� ����� ��� �� ������
  �������� ����������� ���� ����� � �������
  ��������� �������� ���������� � ����

  �������: 123;11;-5;6

*)

function g_ais_getitemscount(A: PAnsiChar): SmallInt;
  cdecl; export;
var
  I: Integer;
begin
  if StrLen(A) = 0 then
  begin
    Result := 0;
    exit;
  end;

  Result := 1;
  I := 0;
  while A[I] > #0 do
  begin
    if A[I] = ';' then
      Result := Result + 1;

    Inc(I);
  end;
end;

function g_ais_getitembyindex(A: PAnsiChar; var Index: SmallInt): Integer;
  cdecl; export;
var
  B, E: PAnsiChar;
  S: array[0..255] of AnsiChar;
begin
  B := A;
  while (Index > 0) and (B^ <> #0) do
  begin
    if B^ = ';' then
      Dec(Index);
    Inc(B);
  end;

  E := B;
  while (E^ <> #0) and (E^ <> ';') do
    Inc(E);

  Result := StrToInt(StrPas(StrLCopy(S, B, E - B)));
end;

function g_ais_inarray(A: PAnsiChar; var I: Integer): SmallInt;
  cdecl; export;
var
  K, J: SmallInt;
begin
  Result := 0;

  for K := 0 to g_ais_getitemscount(A) - 1 do
  begin
    J := K;
    if g_ais_getitembyindex(A, J) = I then
    begin
      Result := 1;
      exit;
    end;
  end;
end;


// Buffer size, to read BLOb in
const
 MaxBufSize = 32768;


// ==============================================
//  declare external function ...
//    BLOb, cstring(255)
//  returns
//    parameter 2
//  ...
// ==============================================
procedure g_blob_info(var BLOb: TBLOb; CString: PAnsiChar); cdecl; export;
begin
  with BLOb do
    if Assigned(Handle) then
      StrLFmt(CString, 255, // Max result AnsiString size
        'number of segments:%d  max. segment length:%d  total length:%d',
        [SegCount, MaxSegLength, TotalLength])
    else
      StrCopy(CString, '<empty BLOb>');
end;

function g_blob_size(var BLOb: TBLOb): Integer; cdecl; export;
begin
  with BLOb do
    if Assigned(Handle) then
      Result := TotalLength
    else
      Result := 0;
end;

function SearchSample(Buf, Sample : PAnsiChar) : Boolean;
begin
  Result := StrPos(Buf, Sample) <> nil;
end;

function FillBuffer(var BLOb : TBLOb; Buf : PAnsiChar; FreeBufLen : Integer;
  var ReadLen : Integer) : Boolean;
var
  EndOfBLOb : Boolean;
  FreeBufLenX, GotLength : Long;
begin
  try
    ReadLen := 0;
    repeat
      GotLength := 0; { !?! }

      if FreeBufLen > MaxBLObPutLength then FreeBufLenX := MaxBLObPutLength
      else FreeBufLenX := FreeBufLen;

      with BLOb do
        EndOfBLOb := not GetSegment(Handle, Buf + ReadLen, FreeBufLenX, GotLength);

      Inc(ReadLen, GotLength);
      Dec(FreeBufLen, GotLength);
    until EndOfBLOb or (FreeBufLen = 0);
  except
    on E: Exception do begin
      {$Ifdef Debug}
        Writeln(X, E.Message);
        Writeln(X, ReadLen, ' ', FreeBufLen, ' ', GotLength, ' ', EndOfBLOb);
        Flush(X);
      {$Endif}
      EndOfBLOb := True;
    end;
  end;
  Buf[ReadLen] := #0;
  Result := EndOfBLOb;
end;


// ==============================================
//  declare external function ...
//    BLOb, cstring(1)
//  returns
//    integer by value
//  ...
// ==============================================
function g_blob_search(var BLOb : TBLOb; KeyWord : PAnsiChar) : Integer; cdecl; export;
var
  KeyWordLen, ReadLength, Offset : Integer;
  EndOfBLOb, Found : Boolean;
  Buf : PAnsiChar;
begin
  Result := 0;
  with BLOb do
    if (not Assigned(Handle)) or (TotalLength = 0) then Exit;

  Result := -2;
  KeyWordLen := StrLen(KeyWord) - 1;
  if KeyWordLen >= MaxBufSize then Exit;

  Found := False;
  GetMem(Buf, MaxBufSize + 1);
  try
    Result := -1;
    if not Assigned(Buf) then Exit;

    Offset := 0;
    repeat
      EndOfBLOb := FillBuffer(BLOb, Buf + Offset, MaxBufSize - Offset, ReadLength);

      if ReadLength + Offset >= KeyWordLen then begin
        Found := SearchSample(Buf, KeyWord);
        SysUtils.StrMove(Buf, Buf + ReadLength + Offset - KeyWordLen, KeyWordLen);
        Offset := KeyWordLen;
      end
      else
        Offset := Offset + ReadLength; // Only at the end of BLOb
    until EndOfBLOb or Found;

  finally
    FreeMem(Buf, MaxBufSize + 1);
  end;

  Result := Integer(Found);
end;


const
  MaxVarCharLength = 32767; // Max [Var]AnsiChar length

procedure g_blob_blobtocstring(var BLOb: TBLOb; CString: PAnsiChar); cdecl; export;
var
  ReadLength: Integer;
begin
  try
    CString[0] := #0;
    with BLOb do
      if (not Assigned(Handle)) or (TotalLength = 0) then Exit;

    FillBuffer(BLOb, CString, MaxVarCharLength - 1, ReadLength);
  except
    {$Ifdef Debug}
      on E: Exception do begin
        Writeln(X, 'Exception in BLObToCString!!!');
        Writeln(X, '>', CString, '< ');
        Writeln(X, StrLen(CString), ' ', ReadLength);
        Writeln(X, E.Message);
        Flush(X);
      end;
    {$Endif}
  end;
end;

(*
function g_s_blobtocstring(var BLOb: TBLOb): PAnsiChar;
  cdecl; export;
var
  ReadLength: Integer;
  CString: PAnsiChar;
begin
  try
    CString[0] := #0;
    with BLOb do
      if (not Assigned(Handle)) or (TotalLength = 0) then Exit;

    FillBuffer(BLOb, CString, MaxVarCharLength - 1, ReadLength);
  except
    {$Ifdef Debug}
      on E: Exception do begin
        Writeln(X, 'Exception in BLObToCString!!!');
        Writeln(X, '>', CString, '< ');
        Writeln(X, StrLen(CString), ' ', ReadLength);
        Writeln(X, E.Message);
        Flush(X);
      end;
    {$Endif}
  end;
  Result := CString;
end;
*)

procedure g_blob_cstringtoblob(CString: PAnsiChar; var BLOb: TBLOb); cdecl; export;
var
  CStringLength, PutLength: Long;
begin
  try
    CStringLength := StrLen(CString);
    if CStringLength = 0 then Exit; // Is it possible to set BLOb = null when
                                    // StrLen(CString) = 0 ?
    with BLOb do
      if not Assigned(Handle) then Exit;

    while CStringLength > 0 do begin
      if CStringLength > MaxBLObPutLength then PutLength := MaxBLObPutLength
      else PutLength := CStringLength;

      with BLOb do
        PutSegment(Handle, CString, PutLength);

      Dec(CStringLength, PutLength);
      Inc(CString, PutLength);
    end;

  except
    {$Ifdef Debug}
      on E: Exception do begin
        Writeln(X, 'Exception in CStringToBLOb!!!');
        Writeln(X, '>', CString, '< ');
        Writeln(X, StrLen(CString), ' ', CStringLength);
        Writeln(X, E.Message);
        Flush(X);
      end;
    {$Endif}
  end;
end;

function g_his_create: Integer;
  cdecl; export;
var
  I: Integer;
begin
  Result := -1;
  csHugeIntSet.Enter;
  try
    for I := 0 to HugeIntSetMaxCount - 1 do
    begin
      if arrHugeIntSet[I] = nil then
      begin
        arrHugeIntSet[I] := TgsHugeIntSet.Create;
        Result := I;
        break;
      end;
    end;
  finally
    csHugeIntSet.Leave;
  end;
end;

function g_his_exclude(var AnIndex: Integer; var AnElement: Integer): Integer;
  cdecl; export;
begin
  Result := 0;
  if arrHugeIntSet[AnIndex] <> nil then
  begin
    arrHugeIntSet[AnIndex].Exclude(AnElement);
    Result := 1;
  end;
end;

function g_his_include(var AnIndex: Integer; var AnElement: Integer): Integer;
  cdecl; export;
begin
  Result := 0;
  if arrHugeIntSet[AnIndex] <> nil then
  begin
    arrHugeIntSet[AnIndex].Include(AnElement);
    Result := 1;
  end;
end;

function g_his_has(var AnIndex: Integer; var AnElement: Integer): Integer;
  cdecl; export;
begin
  if arrHugeIntSet[AnIndex] <> nil then
    Result := Integer(arrHugeIntSet[AnIndex].Has(AnElement))
  else
    Result := 0;
end;

function g_his_destroy(var AnIndex: Integer): Integer;
  cdecl; export;
begin
  Result := 0;
  csHugeIntSet.Enter;
  try
    if arrHugeIntSet[AnIndex] <> nil then
    begin
      FreeAndNil(arrHugeIntSet[AnIndex]);
      Result := 1;
    end;
  finally
    csHugeIntSet.Leave;
  end;
end;

var
  I: Integer;

initialization
  csHugeIntSet := TCriticalSection.Create;
  for I := 0 to HugeIntSetMaxCount - 1 do
    arrHugeIntSet[I] := nil;

finalization
  csHugeIntSet.Free;
  {$WARNINGS OFF}
  for I := 0 to HugeIntSetMaxCount - 1 do
    arrHugeIntSet[I].Free;
  {$WARNINGS ON}
end.
