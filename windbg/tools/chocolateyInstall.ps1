param(
    [string] $SymbolPath = "$env:SYSTEMROOT\Symbols"
)

$ErrorActionPreference = 'Stop';

$arguments = @{}

$packageParameters = $env:chocolateyPackageParameters

# Now parse the packageParameters using good old regular expression
if ($packageParameters) {
    $match_pattern = "\/(?<option>([a-zA-Z]+)):(?<value>([`"'])?([a-zA-Z0-9- _\\:\.]+)([`"'])?)|\/(?<option>([a-zA-Z]+))"
    $option_name = 'option'
    $value_name = 'value'

    if ($packageParameters -match $match_pattern ){
        $results = $packageParameters | Select-String $match_pattern -AllMatches
        $results.matches | % {
        $arguments.Add(
            $_.Groups[$option_name].Value.Trim(),
            $_.Groups[$value_name].Value.Trim())
        }
    }
    else
    {
        Throw "Package Parameters were found but were invalid (REGEX Failure)"
    }

    if ($arguments.ContainsKey("SymbolPath")) {
        $SymbolPath = $arguments["SymbolPath"]
    }
} else {
    Write-Debug "No Package Parameters Passed in"
}

$tempFolder = "$env:temp\chocolatey\windbg"
mkdir $tempFolder -ErrorAction SilentlyContinue | Out-Null

$files = @{
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/SDK%20Debuggers-x86_en-us.msi" = "33AEB814E0F99F2027F4ED0FF2F91889";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/34ef8c7e30b6852e56ba7a56fb7b3faa.cab" = "F6557EA5F0701410BE6B42618B6B2435";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/e680f23450a21a27b2077dbdc08ca430.cab" = "FF06D59F5230D7B8F6D78E4D9E8C621C";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/4040fdfbcd753e650c0e3a5bce3ed7a2.cab" = "1248A55A46600737DD273F0B5F99C724";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/e10f9740446a96314a1731aa7cb4286a.cab" = "D7E4896BD662EAFE11412DCFD0F7359F";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/7178f554c01f912c749b622564106b02.cab" = "E6A27725141538A58AC0E2226E9289D4";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/bd4b6e22633abadb45b75bc86caaa120.cab" = "1E7E9544694A21CF1CA5AFC70BB243F2";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/6d946492af1c4bd35fcc60ab2057db4a.cab" = "A50670F562557C9A5AB394E639D732A4";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/3bcfd9f5ea63604c64ec7e0f5455a840.cab" = "AFAF76532649389EDCE9CDAC974F486E";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/7ba8bd916cfe6a56d86eaab1543d1205.cab" = "05AD431F6D7BE533897862E8235B90BC";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/0253f7df0974f9d7169b410d812a5385.cab" = "D9D658016FC4128E9E93E6BFEF6AC81B";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/9fff62eb37dba61a297941c75287dfec.cab" = "92FC29C46FAB8F15015654D8AB328B91";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/e8bc712abeffd7c9711ee3f55d4aa99b.cab" = "D0C1E2F428104CD1AD696E1E222E54D5";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/caab1106d57ff70cb3cbd8350a77e871.cab" = "86E1106C831BF6E89B7DFD170D5F907A";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/44ae31259cff28faf5e7015a9b8be5b2.cab" = "FC3C38FB69ADE846E5CFD735809410D1";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/5f7ef4904f75bf6b3b9b0f8975ad1492.cab" = "63120DF483B331E8E6684D3EDAA2AEC2";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/a74408a87a51829b89e5282e73974d74.cab" = "45B02B55383FAC3D500EA0E7D542809E";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/5697d8a4098ded6eb49417251c138643.cab" = "54EB816B104806FCCC81F0B8FCC0068D";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/dc19fbd16e9708e0bc4d8419e3a7d48d.cab" = "77D142ECC4029AADCC0C7AA244029B60";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/2f7b48ba67113253720675dbbbe9df33.cab" = "8BAE0A8B3D0B54859B9C96C9A349E312";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/65f45ddc30ad5fc4f9873e7791f83dac.cab" = "F39036260E4BAA91A54C7435F878E6C2";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/fe80f1b6d4cf60c919f4b3a0cd2f4306.cab" = "80B2C148576003603D1491C2193C7492";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/8f636cea16f07b14f423402afc69cf83.cab" = "183640A98161570998ECF37AA792F983";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/802a07e87c65fbd441584c31e8bb0ea7.cab" = "1C03B3A08281F99CEC70343C4BF71043";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/54a71dd657698028e27ce58b8c8f477a.cab" = "8FD3E5A602917839F6EB25D0DF6CFA86";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/72bda6e16f5c7a040361c1304b4b5b36.cab" = "173368F09368EED83FC41B0783F96B3C";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/b98a31e36735eb82b3b238c68f36fbbf.cab" = "5E09329C7E149989AB1F4307FB05F927";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/114c321d61ae77816824fed67cd25704.cab" = "5FB79CC62714BA65F1B064B290ACB5A5";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/3a53dffe0b4548753bc34825894f19bf.cab" = "8016C9275DF41F9027C586FD9E7DC4C5";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/d55d1e003fbb00a12c63b8f618e452bf.cab" = "5908FF47B65DB689B9103E39C281185B";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/9f17b927fd84ebb5ee0df0774c0c568f.cab" = "4B19F5381E023818866A7E24D383C879";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/2c1331a0f4ecc46dfa39f43a575305e0.cab" = "FC4C607AB9E757BD9B2FDA42FB6C29E6";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/ba5d20281a858248e59d96d75c014391.cab" = "3E48A589FDE157D9F0003733DFDF02AD";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/dcb0a55d6cacaa05ead299e1d3de3c6d.cab" = "4ADDE8C147A912356FF42BFBED97AAF7";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/678f64f35c507af8a9af0532b9b211ec.cab" = "B21D224A39F4B2F3F8274393AE457A43";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/2c1817d3f3f33cd01376c5ec441cc636.cab" = "A4A2A3DE6802EC37A4586E964669FDE2";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/4c576e9c56c314d28a0e9d10ab87ca67.cab" = "6276E943BBD0537A893F50AFBC9AB7C8";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/437e52bd67ebe977a8957439db5ecf75.cab" = "B391AB50AD4F9F169C989F1B8ADFD7F0";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/baa2d817ae180ba7e772f1543c3bbdea.cab" = "0486AA4B9F61D6BBDFE1AF0AFDD9A37E";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/aac61496dd6fee21a0e5627e4dcd8488.cab" = "45A18ADD0C6558F16FA23C3FE013C133";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/75b302463eed0d9b6ef9f29ebb655ef9.cab" = "91722DF56BDAD9A5197A17243A8C9965";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/4ac48dbdddbc8ce04721f519b9cf1698.cab" = "AE206A14F2194B25746BFE620EFD61F8";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/5642ea5ea549365f8b2a4f885b407d18.cab" = "304D8B6BB0B24E14EEA8DBAE143F20B5";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/96e8f767221532c6446fd1b8dad53b60.cab" = "D5DEF4408EC5E8C6D131E74076819BE3";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/7cb1ba9318f4b586c6a3bdd541e7f3ad.cab" = "2518DD2080BFD436D059890481DB23AD";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/f524b9054edb102e11fe3850fc6796ca.cab" = "00567A10A514AA74D96D2E78A5A91DFF";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/8eb01de6160e8924be8582861808a9b5.cab" = "D41ED9A6B63B260259DD5D25A9841CD7";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/79e9b68a34bc84ab465fe1b79b84a325.cab" = "548A9E5BF68B7A4ADE21EB56D858258E";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/34ee98a7c9420178c55f176f75c3fe10.cab" = "08DCD1D4726231DA7935509194959B2C";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/ab8c11616091812d6c7137e366ba1d8d.cab" = "7F55F859D3BBAB85E6F683AA5D8E1797";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/6bc159aa6f35510d049f0639e0ddb277.cab" = "971280C482A72C096112A14FED5CD588";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/3ca392fde3898c3be052ddcddd14bb5f.cab" = "FE1F2CA9AAD1CF13FFB4D31079086B29";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/3960f55df7c8073f3997269e5e390abc.cab" = "B770A6DF7163D934BFDB07ED34A87325";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/4de7a1422374f98369172705b05d4bf9.cab" = "1A304B252E60FA52860622C9FDDD03A4";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/412c1caad96b8fe5e8f7f6735585f297.cab" = "A7B7936F4E4EC506345CA57CFB9C219E";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/1a822224523be67061edcc97f6c0e36a.cab" = "A1303100B1A216047427250FCE38D4E9";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/X86%20Debuggers%20And%20Tools-x86_en-us.msi" = "54300B7D13C4E850F1B677C14A539599";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/X64%20Debuggers%20And%20Tools-x64_en-us.msi" = "B192E28F856F1C6ADBF20379C4A17AE7";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/dotNetFx45_Full_x86_x64.exe" = "D02DC8B69A702A47C083278938C4D2F1";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/Kits%20Configuration%20Installer-x86_en-us.msi" = "52480A40FF8F743614019D980FE31C04";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/Windows%20SDK%20EULA-x86_en-us.msi" = "67FDA36E5842E89D7DD5DDCA3C6D990C";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/931721e121ef91707ddcb6cac354d95c.cab" = "AA584D32795504FBD6D4710BF179FABD";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/4e2dea081242e821596b58b31bc22cca.cab" = "6AED270CA119BE455BBBAFF252DF3EB7";
[uri] "https://download.microsoft.com/download/1/c/3/1c3d5161-d9e9-4e4b-9b43-b70fe8be268c/windowssdk/Installers/598442d9f84639d200d4f3af477da95c.cab" = "0C611D956766BD89D7018619389762C7";
}

foreach ($file in $files.GetEnumerator()) {    
    Get-ChocolateyWebFile -PackageName "windbg" -url $file.Key.AbsoluteUri -Checksum $file.Value -checksumType MD5 -FileFullPath ([System.IO.Path]::Combine($tempFolder, [System.IO.Path]::GetFilename($file.Key.LocalPath)))
}

Install-ChocolateyInstallPackage "windbg" "msi" "/q" "$tempFolder\SDK Debuggers-x86_en-us.msi"

if(${env:ProgramFiles(x86)} -ne $null){ $programFiles86 = ${env:ProgramFiles(x86)} } else { $programFiles86 = $env:ProgramFiles }
$windbgPath = (Join-Path $programFiles86 "Windows Kits\10\Debuggers")

[Environment]::SetEnvironmentVariable( '_NT_SYMBOL_PATH', "symsrv*symsrv.dll*$SymbolPath*http://msdl.microsoft.com/download/symbols", 'User')
$env:_NT_SYMBOL_PATH = "symsrv*symsrv.dll*$SymbolPath*http://msdl.microsoft.com/download/symbols"

$fxDir = "$env:windir\Microsoft.NET\Framework"
if(Test-Path $fxDir) {
    $frameworksx86 = dir "$fxdir\v*" | ? { $_.psiscontainer -and $_.Name -match "v[0-9]" }
}

$statement = @"
    copy-item (join-path '$($frameworksx86[-1])' "sos.dll") '$windbgPath\x86';
    copy-item '$windbgPath\x86\windbg.exe' '$windbgPath\x86\windbgx86.exe';
    Install-ChocolateyDesktopLink '$windbgPath\x64\windbg.exe';
    Install-ChocolateyDesktopLink '$windbgPath\x86\windbgx86.exe';
"@
$fxDir = "${fxdir}64"
if(Test-Path $fxDir) {
    $frameworksx64 = dir "$fxdir\v*" | ? { $_.psiscontainer -and $_.Name -match "v[0-9]"}
    $statement += @"
    copy-item (join-path '$($frameworksx64[-1])' "sos.dll") '$windbgPath\x64';
"@
    }
    
Start-ChocolateyProcessAsAdmin "$statement" -minimized -nosleep
