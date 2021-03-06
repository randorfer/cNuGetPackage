function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [parameter(Mandatory = $true)]
        [System.String]
        $LocalGitRepositoryRoot,

        [parameter(Mandatory = $true)]
        [System.String]
        $RepositoryPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $Branch
    )
    
    $RepositoryName = $RepositoryPath.Split('/')[-1]
    $StartingDir = (pwd).Path
    Try
    {
        Set-Location -Path "$($LocalGitRepositoryRoot)\$($RepositoryName)"
        $BranchOutput = git branch
        if((($BranchOutput -Match '\*') -as [string]) -Match "\* (.*)")
        {
            $Branch = $Matches[1]
        }
        else
        {
            $Branch = [string]::Empty
        }
    }
    Catch { throw }
    Finally { Set-Location -Path $StartingDir }
                
    Return @{
        'RepositoryPath' = $RepositoryPath
        'LocalGitRepositoryRoot' = $LocalGitRepositoryRoot
        'Branch' = $Branch
    }
}
Export-ModuleMember -Function Get-TargetResource -Verbose:$false


function Set-TargetResource
{
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [System.String]
        $LocalGitRepositoryRoot,

        [parameter(Mandatory = $true)]
        [System.String]
        $RepositoryPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $Branch
    )
    $StartingDir = (pwd).Path
    Try
    {
        Set-Location -Path "$($LocalGitRepositoryRoot)\$($RepositoryName)"
        $EAPHolder = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'
        $Null = git checkout $Branch
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]$EAPHolder
    }
    Catch { throw }
    Finally { Set-Location -Path $StartingDir }
}
Export-ModuleMember -Function Set-TargetResource -Verbose:$false


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [parameter(Mandatory = $true)]
        [System.String]
        $LocalGitRepositoryRoot,

        [parameter(Mandatory = $true)]
        [System.String]
        $RepositoryPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $Branch
    )

    $Status = Get-TargetResource -LocalGitRepositoryRoot $LocalGitRepositoryRoot -RepositoryPath $RepositoryPath -Branch $Branch

    Return ($Status.Branch -eq $Branch) -as [bool]
}
Export-ModuleMember -Function Test-TargetResource -Verbose:$false

