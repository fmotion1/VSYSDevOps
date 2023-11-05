function Save-LicenseToFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Folder,
    
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateSet(   'MIT', 'MIT-No-Attribution', 'BSD2-Clause-Simplified', 
                        'BSD3-Clause-New-or-Revised', 'ISC', 'Unlicense',
                        'Apache-License-2', 'GNU-GPL-v2', 'GNU-GPL-v3',
                        'Mozilla-Public-v2', 'SIL-Open-Font-v11'
                    )]
        [String]
        $LicenseType,
    
        [Parameter(Mandatory=$false)]
        [Switch]
        $Force
    )
    
    begin {
        switch ($LicenseType) {
            "MIT"                        {$LicensePath = "$PSScriptRoot\..\Templates\LICENSE\MIT\LICENSE"}
            "MIT-No-Attribution"         {$LicensePath = "$PSScriptRoot\..\Templates\LICENSE\MIT No Attribution\LICENSE"}
            "BSD2-Clause-Simplified"     {$LicensePath = "$PSScriptRoot\..\Templates\LICENSE\BSD 2-Clause Simplified\LICENSE"}
            "BSD3-Clause-New-or-Revised" {$LicensePath = "$PSScriptRoot\..\Templates\LICENSE\BSD 3-Clause New or Revised\LICENSE"}
            "ISC"	                     {$LicensePath = "$PSScriptRoot\..\Templates\LICENSE\ISC\LICENSE"}
            "Unlicense"                  {$LicensePath = "$PSScriptRoot\..\Templates\LICENSE\The Unlicense\LICENSE"}
            "Apache-License-2"	         {$LicensePath = "$PSScriptRoot\..\Templates\LICENSE\Apache License 2.0\LICENSE"}
            "GNU-GPL-v2"	             {$LicensePath = "$PSScriptRoot\..\Templates\LICENSE\GNU GPL v2.0\LICENSE"}
            "GNU-GPL-v3"	             {$LicensePath = "$PSScriptRoot\..\Templates\LICENSE\GNU GPL v3.0\LICENSE"}
            "Mozilla-Public-v2"	         {$LicensePath = "$PSScriptRoot\..\Templates\LICENSE\Mozilla Public 2.0\LICENSE"}
            "SIL-Open-Font-v11"	         {$LicensePath = "$PSScriptRoot\..\Templates\LICENSE\SIL Open Font 1.1\LICENSE"}
        }
    }
    
    process {
        $DestLicense = Join-Path $Folder 'LICENSE'
        $LicenseExists = Test-Path -LiteralPath $DestLicense -PathType Leaf

        if((!$LicenseExists) -or $Force){
            [IO.File]::Copy($LicensePath, $DestLicense, $true)
        }
    }
}
