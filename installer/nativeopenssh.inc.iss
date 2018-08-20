[Code]
#ifdef UNICODE
#define AW "W"
#else
#define AW "A"
#endif

# Function from https://stackoverflow.com/questions/32024362/innosetup-expand-environment-variable-taken-from-registry-value-using-reg
function ExpandEnvironmentStrings(lpSrc: String; lpDst: String; nSize: DWORD): DWORD;
external 'ExpandEnvironmentStrings{#AW}@kernel32.dll stdcall';

# Function from https://stackoverflow.com/questions/32024362/innosetup-expand-environment-variable-taken-from-registry-value-using-reg
function ExpandEnvVars(const Input: String): String;
var
  Buf: String;
  BufSize: DWORD;
begin
  BufSize := ExpandEnvironmentStrings(Input, #0, 0);
  if BufSize > 0 then
  begin
    SetLength(Buf, BufSize);  // The internal representation is probably +1 (0-termination)
    if ExpandEnvironmentStrings(Input, Buf, BufSize) = 0 then
      RaiseException(Format('Expanding env. strings failed. %s', [SysErrorMessage(DLLGetLastError)]));
#if AW == "A"
    Result := Copy(Buf, 1, BufSize - 2);
#else
    Result := Copy(Buf, 1, BufSize - 1);
#endif
  end
  else
    RaiseException(Format('Expanding env. strings failed. %s', [SysErrorMessage(DLLGetLastError)]));
end;

function IsNativeOpenSSHAvailable(): Boolean;
begin
  Result := FileExists(ExpandEnvVars('SystemRoot') + 'System32\OpenSSH\ssh.exe') or
            FileExists(ExpandEnvVars('SystemRoot') + 'Sysnative\OpenSSH\ssh.exe');
end;
