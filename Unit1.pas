unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Abcspin, SkinData, DynamicSkinForm,
  SkinCtrls, SkinBoxCtrls, Mask, spcalendar, ExtCtrls, spTrayIcon,
  Abcexctl;

const
  WM_SUTDOWN = WM_USER + 101;

type
  TMain = class(TForm)
    spDynamicSkinForm1: TspDynamicSkinForm;
    spSkinData1: TspSkinData;
    spSkinEdit1: TspSkinEdit;
    spSkinMonthCalendar1: TspSkinMonthCalendar;
    spSkinGroupBox1: TspSkinGroupBox;
    spSkinSpinEdit1: TspSkinSpinEdit;
    spSkinSpinEdit2: TspSkinSpinEdit;
    spSkinLabel1: TspSkinStdLabel;
    spSkinLabel2: TspSkinStdLabel;
    Timer1: TTimer;
    spSkinButton1: TspSkinButton;
    spSkinButton2: TspSkinButton;
    spTrayIcon1: TspTrayIcon;
    abcClockLabel1: TabcClockLabel;
    spSkinStdLabel2: TspSkinStdLabel;
    spSkinLabel3: TspSkinLabel;
    spSkinGroupBox2: TspSkinGroupBox;
    spSkinStdLabel1: TLabel;
    spCompressedStoredSkin1: TspCompressedStoredSkin;
    spSkinCheckRadioBox1: TspSkinCheckRadioBox;
    procedure FormCreate(Sender: TObject);
    procedure spSkinButton2Click(Sender: TObject);
    procedure spSkinButton1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    GioBD, PhutBD: Word;
    GioKT, PhutKT, GiayKT: Word;
    procedure WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    procedure WMSutdown(var Message: TMessage); message WM_SUTDOWN;
  public
    { Public declarations }
  end;

var
  Main: TMain;

implementation

{$R *.dfm}

uses GetFolders;

procedure TMain.FormCreate(Sender: TObject);
begin
  Caption := 'Hẹn thời gian Máy tính tự động tắt';
  spSkinGroupBox1.Caption := 'Đặt thời gian';
  spSkinLabel1.Caption := 'Giờ :';
  spSkinLabel2.Caption := 'Phút :';
  spSkinButton1.Caption := 'Bắt đầu';
  spSkinButton2.Caption := 'Dừng lại';
  spSkinGroupBox2.Caption := 'Máy tính sẽ tắt sau :';
  spSkinCheckRadioBox1.Caption := 'Máy tính vào trạng thái NGỦ ĐÔNG';
  spSkinButton2Click(self);
end;

procedure ShutdownComputer;
var
  ph: THandle;
  tp, prevst: TTokenPrivileges;
  rl: DWORD;
begin
  OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or
    TOKEN_QUERY, ph);
  LookupPrivilegeValue(nil, 'SeShutdownPrivilege', tp.Privileges[0].Luid);
  tp.PrivilegeCount := 1;
  tp.Privileges[0].Attributes := 2;
  AdjustTokenPrivileges(ph, FALSE, tp, SizeOf(prevst), prevst, rl);
  ExitWindowsEx(EWX_SHUTDOWN or EWX_POWEROFF, 0);
end;

procedure RebootSystem2000;
var
  handle_: THandle;
  n: DWORD;
  luid: TLargeInteger;
  priv: TOKEN_PRIVILEGES;
  ver: TOSVERSIONINFO;
begin
 OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES, handle_);
 if LookupPrivilegeValue(nil, 'SeShutdownPrivilege', luid) then
   begin
     priv.PrivilegeCount := 1;
     priv.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
     priv.Privileges[0].Luid := luid;
     AdjustTokenPrivileges(handle_, false, priv, 0, nil, n);
   end;
  ExitWindowsEx(EWX_POWEROFF,1);
end;



procedure XP_Win9X_Shutdown;
var
  TokenHandle: THandle;
  RetLength: Cardinal;
  TP: TTokenPrivileges;
begin
  OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES
    or TOKEN_QUERY, TokenHandle);
  if LookupPrivilegeValue(nil, 'SeShutdownPrivilege',
    TP.Privileges[0].Luid) then
  begin
    TP.PrivilegeCount := 1;
    TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
    RetLength := 0;
    if AdjustTokenPrivileges(TokenHandle, FALSE, TP, 0, nil, RetLength) then
    begin
      if not SetProcessShutdownParameters($4FF, SHUTDOWN_NORETRY) then
      begin
        MessageBox(0, 'Shutdown failed', nil, MB_OK or MB_ICONSTOP);
      end
      else
      begin
        ExitWindowsEx(EWX_FORCE or EWX_SHUTDOWN, 0);
      end;
      exit;
    end;
  end else
    WinExec('RUNDLL.EXE user.exe,exitwindows',SW_SHOWNORMAL);
end;

 var
   _SetSuspendState: function (Hibernate, ForceCritical, DisableWakeEvent: BOOL): BOOL
   stdcall = nil;

   function LinkAPI(const module, functionname: string): Pointer; forward;

 function SetSuspendState(Hibernate, ForceCritical,
   DisableWakeEvent: Boolean): Boolean;
 begin
   if not Assigned(_SetSuspendState) then
     @_SetSuspendState := LinkAPI('POWRPROF.dll', 'SetSuspendState');
   if Assigned(_SetSuspendState) then
     Result := _SetSuspendState(Hibernate, ForceCritical,
       DisableWakeEvent)
   else
     Result := False;
 end;

 function LinkAPI(const module, functionname: string): Pointer;
 var
   hLib: HMODULE;
 begin
   hLib := GetModulehandle(PChar(module));
   if hLib = 0 then
     hLib := LoadLibrary(PChar(module));
   if hLib <> 0 then
     Result := getProcAddress(hLib, PChar(functionname))
   else
     Result := nil;
 end;

procedure HibernateWindows;
begin
  SetSuspendState(True, False, False);
end;



procedure TMain.spSkinButton2Click(Sender: TObject);
begin
  spSkinStdLabel2.Visible := false;
  spSkinLabel3.Visible := false;
  spSkinSpinEdit1.Value := 0;
  spSkinSpinEdit2.Value := 0;
  Timer1.Enabled := false;
  spSkinStdLabel1.Caption := '00:00:00';
  spSkinButton1.Enabled := true;
end;

procedure TMain.spSkinButton1Click(Sender: TObject);
var Gio, Phut, Giay, MiliGiay: Word;
    GiayTemp: Int64;
begin
  if ((spSkinSpinEdit1.Value = 0) and
      (spSkinSpinEdit2.Value = 0)) or
      Timer1.Enabled then Exit;
  spSkinStdLabel2.Visible := true;
  spSkinStdLabel2.Caption := 'Thời điểm đặt giờ tắt máy:';
  Timer1.Enabled := true;
  GioBD := Round(spSkinSpinEdit1.Value);
  PhutBD := Round(spSkinSpinEdit2.Value);
  DecodeTime(Time, Gio, Phut,Giay, MiliGiay) ;
  GioKT := Gio + GioBD;
  PhutKT := Phut + PhutBD;
  GiayKT := Giay;
  GiayTemp := (GioKT*3600 + PhutKT*60 + GiayKT);
  GioKT := GiayTemp div 3600;
  PhutKT := (GiayTemp mod 3600) div 60;
  GiayKT := (GiayTemp mod 3600) mod 60;
  spSkinLabel3.Caption := abcClockLabel1.Caption;
  spSkinLabel3.Visible := true;
  spSkinButton1.Enabled := false;
end;

procedure TMain.Timer1Timer(Sender: TObject);
var Gio, Phut, Giay, MiliGiay: Word;
    st1, st2,st3: string;
    GioDoi: int64;
begin
  DecodeTime(Time, Gio, Phut, Giay, MiliGiay) ;
  GioDoi := (GioKT*3600 + PhutKT*60 + GiayKT) - (Gio*3600 + Phut*60 + Giay);
  if (GioKT >= 24) and (Gio = 0) then
    GioKT := GioKT - 24;
  st1 := IntToStr(GioDoi div 3600);
  st2 := IntToStr((GioDoi mod 3600) div 60);
  st3 := IntToStr((GioDoi mod 3600) mod 60);
  if length(st1) = 1 then st1 := '0' + st1;
  if length(st2) = 1 then st2 := '0' + st2;
  if length(st3) = 1 then st3 := '0' + st3;
  spSkinStdLabel1.Caption := st1 + ':' + st2 + ':' + st3;
  if (GioKT = Gio) and
     (PhutKT = Phut) and
     (GiayKT = Giay) then
       begin
         PostMessage(Handle, WM_SUTDOWN ,0 , 0);
         Timer1.Enabled := false;
       end;
end;

procedure TMain.WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
begin
  inherited;
  Msg.MinMaxInfo.ptMinTrackSize.X := 475;
  Msg.MinMaxInfo.ptMinTrackSize.Y := 278;
  Msg.MinMaxInfo.ptMaxTrackSize.X := 475;
  Msg.MinMaxInfo.ptMaxTrackSize.Y := 278;
end;

procedure TMain.WMSutdown(var Message: TMessage);
begin
  if GetWindowsVersion in
   [wvUnknown, wvWin95, wvWin95OSR2, wvWin98, wvWin98SE,wvWinME] then
    XP_Win9X_Shutdown else
  if GetWindowsVersion in [wvWinNT3, wvWinNT4, wvWin2000] then
    begin
      if spSkinCheckRadioBox1.Checked then
        begin
          HibernateWindows;
          Close;
        end                           else
               RebootSystem2000;
    end;
end;

end.
