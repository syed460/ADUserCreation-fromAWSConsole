##update the bucket path while reusing the script for AWS env
param(
    [Parameter(Mandatory)]$csvfilename,
    [string]$user,
    [string]$password,
    [string]$continue
    )

$scriptpath = "C:\AD_Operations\New_User_Creation\"

#---------------------------------Variables

$LogFile = $scriptpath + "Logs\$($domain.Name)_ADUserAccount_Creation_Logs-$(((get-date).ToUniversalTime()).ToString("MMddyyyyThhmmssZ")).txt"
Start-Transcript -Path $LogFile

$var = Get-Content $($scriptpath +"var.json") | ConvertFrom-Json
$bucketpath= $var.BucketPatch

<#
$csvfilename = $args[0] #csv filename should be with extention .csc
$user = $args[1]
$password = $args[2]
$continue = $args[3] #to create users from Run command    
#>

$copytopath = $scriptpath
#---------------------------------


#--------function2 


function Import-CreateUser {
    $ErrorActionPreference = "Continue"

    Write-Output " "
    

    $ADUsers = Import-Csv -Path $($copytopath+ $csvfilename) #+ ".csv"
    $ADUsers | Format-Table

    #Remove the file from system
    Remove-Item $($scriptpath + $csvfilename)

    if ($continue -eq 'yes'){

        Write-Output "Proceeding to create the users"
    }else{
        $continue = Read-Host "Enter [y/Y] to continue"
        if ($continue -eq 'y'){
            Write-Output "Proceeding to create the users"
        }else{
            Write-Output "Entered value is not [y/Y]"
            break
    }
    }



    if ($user -and $password){
        
        Write-Output "`nUsing $user credentials to create user"
        $Secure_password = ConvertTo-SecureString $password -AsPlainText -Force
    }else{
        Write-output "Enter the Admin User Credentials for the operation`n"
        $user = Read-Host "Enter Admin-Username"
        $Secure_password = Read-Host "Enter Password" -AsSecureString
        Write-Output "`nUsing $user credentials to create user"
    }


    $credentials = New-Object -typename System.Management.Automation.PSCredential $user, $Secure_password
    Import-Module ActiveDirectory
    $domain_name = Get-ADDomain | select -Property dnsroot

    foreach ($User in $ADUsers)
    {
	    #Read user data from each field in each row and assign the data to a variable as below
		
	    $Username = $User.username
	    #$OU = $User.ou #This field refers to the OU the user account is to be created in
        $description = $User.description
	    $email = $User.email
        $Password = $User.password
	    $AdGroup = $User.memberof
        $AdGroup1 = $User.memberof1
        $AdGroup2 = $User.memberof2
        $upn = $Username +'@'+ $domain_name.dnsroot
        
	    #Check to see if the user already exists in AD
	    if (Get-ADUser -F {SamAccountName -eq $Username} -Credential $credentials)
	    {
		     #If user does exist, give a warning
		     Write-Warning "A user account with username $Username already exist in $($domain.NetBIOSName) Active Directory Domain."
	    }
	    else
	    {
		    #User does not exist then proceed to create the new user account
		
            #Account will be created in the OU provided by the $OU variable read from the CSV file
	    New-ADUser `
                -SamAccountName $Username `
                -UserPrincipalName $upn `
                -Name $Username `
                -GivenName $Username `
                -Enabled $True `
                -DisplayName $Username `
                -Description $description `
	            -EmailAddress $email `
                -AccountPassword (convertto-securestring $Password -AsPlainText -Force) `
                -Verbose
	        
                If ($AdGroup) 
                { 
                    Add-ADGroupMember "$AdGroup" $Username -Verbose 
                } 
           
                If ($AdGroup1) 
                { 
                    Add-ADGroupMember "$AdGroup1" $Username -Verbose 
                } 
            
                If ($AdGroup2) 
                { 
                    Add-ADGroupMember "$AdGroup2" $Username -Verbose 
                } 

	    Write-Host "$($domain.NetBIOSName) domain user account for $Username has been created on $(Get-Date) and added it into $AdGroup $AdGroup1 $AdGroup2 AD Groups"
        $getuser = Get-ADUser -Identity $Username
        #set-adobject $getuser.DistinguishedName -protectedFromAccidentalDeletion $true -Verbose
    
        }
    }


}

#function 1 for copy file locally

function Get-CSVfile {
    $ErrorActionPreference = "Stop"
    Write-Output "Provided file name is: $csvfilename"
    try {
        #aws s3 ls $bucketpath
        aws s3 cp $($bucketpath+ $csvfilename) $copytopath
        Start-Sleep -s 1
        
        }catch {
            Write-Error $_
            break
            
            }
    

}

#------------------Main

Write-Output "--------Script Start"
Write-Output " "


Get-CSVfile
Import-CreateUser


Stop-Transcript