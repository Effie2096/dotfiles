$signature = @"
[DllImport("user32.dll")]
public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, UIntPtr pvParam, uint fWinIni);
"@
$systemParamInfo = Add-Type -memberDefinition $signature -Name SloppyFocusMouse -passThru
$newVal = [UintPtr]::new(1) # use 0 to turn it off
$systemParamInfo::SystemParametersInfo(0x1001, 0, $newVal, 2)
