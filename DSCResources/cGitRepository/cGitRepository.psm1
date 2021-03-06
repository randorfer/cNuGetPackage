function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $LocalGitRepositoryRoot,

        [parameter(Mandatory = $true)]
        [System.String]
        $RepositoryPath,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )
    
    $RepositoryName = $RepositoryPath.Split('/')[-1]

    if((Test-Path -Path "$($LocalGitRepositoryRoot)\$($RepositoryName)\.git"))
    {
        $Ensure = 'Present'
    }
    else
    {
        $Ensure = 'Absent'
    }

    Return @{
        'LocalGitRepositoryRoot' = $LocalGitRepositoryRoot
        'RepositoryPath' = $RepositoryPath
        'Ensure' = $Ensure
    }
}
Export-ModuleMember -Function Get-TargetResource -Verbose:$false


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $LocalGitRepositoryRoot,

        [parameter(Mandatory = $true)]
        [System.String]
        $RepositoryPath,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    $StartingDir = (pwd).Path
    Try
    {
        if($Ensure -eq 'Present')
        {
            cd $LocalGitRepositoryRoot
            $EAPHolder = $ErrorActionPreference
            $ErrorActionPreference = 'SilentlyContinue'
            git clone $Using:RepositoryPath --recursive
            $ErrorActionPreference = [System.Management.Automation.ActionPreference]$EAPHolder
        }
        else
        {
            $RepositoryName = $RepositoryPath.Split('/')[-1]
            Remove-Item -Path "$($LocalGitRepositoryRoot)\$($RepositoryName)" -Force -Recurse
        }
    }
    Catch { throw }
    Finally { Set-Location -Path $StartingDir }
}
Export-ModuleMember -Function Set-TargetResource -Verbose:$false


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $LocalGitRepositoryRoot,

        [parameter(Mandatory = $true)]
        [System.String]
        $RepositoryPath,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    $Status = Get-TargetResource -LocalGitRepositoryRoot $LocalGitRepositoryRoot -RepositoryPath $RepositoryPath -Ensure $Ensure

    Return ($Status.Ensure -eq $Ensure) -as [bool]
}
Export-ModuleMember -Function Test-TargetResource -Verbose:$false

