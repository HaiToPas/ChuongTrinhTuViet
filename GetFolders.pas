unit GetFolders;

interface

uses
  Windows;

type
  TWindowsVersion = (wvUnknown, wvWin95, wvWin95OSR2, wvWin98, wvWin98SE,
                     wvWinME, wvWinNT3, wvWinNT4, wvWin2000);
var
  IsWin95: Boolean = False;
  IsWin95OSR2: Boolean = False;
  IsWin98: Boolean = False;
  IsWin98SE: Boolean = False;
  IsWinME: Boolean = False;
  IsWinNT: Boolean = False;
  IsWinNT3: Boolean = False;
  IsWinNT4: Boolean = False;
  IsWin2K: Boolean = False;
  KernelVersionHi: DWORD;

function GetWindowsVersion: TWindowsVersion;
function GetProgramFilesFolders: string;
function GetWindowsSystemFolders: string;

implementation

uses
  Messages, SysUtils;

function GetWindowsVersion: TWindowsVersion;
begin
  Result := wvUnknown;
  case Win32Platform of
    VER_PLATFORM_WIN32_WINDOWS:
      case Win32MinorVersion of
        0..9:
          if Trim(Win32CSDVersion) = 'B' then
            Result := wvWin95OSR2
          else
            Result := wvWin95;
        10..89:
          if KernelVersionHi = $0004005A then
            Result := wvWinME
          else if Trim(Win32CSDVersion) = 'A' then
            Result := wvWin98SE
          else
            Result := wvWin98;
        90:
          Result := wvWinME;
      end;
    VER_PLATFORM_WIN32_NT:
      case Win32MajorVersion of
        3:
          Result := wvWinNT3;
        4:
          Result := wvWinNT4;
        5:
          Result := wvWin2000;
      end;
  end;
end;

function GetProgramFilesFolders: string;
var St: string;
    Path: array[0..MAX_PATH - 1] of Char;
begin
  Result := 'C:\Program Files\HaiViet\';
  GetSystemDirectory(Path, MAX_PATH);
  St := StrPas(Path);
  Result[1] := St[1];
end;

function StrPas(const Str: PChar): string;
begin
  Result := Str;
end;

function GetWindowsSystemFolders: string;
var Path: array[0..MAX_PATH - 1] of Char;
begin
  GetSystemDirectory(Path, MAX_PATH);
  Result := StrPas(Path) + '\';
end;

end.
