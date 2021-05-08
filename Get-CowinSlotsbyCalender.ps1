<#
 .Synopsis
  Get the CowinSlotsbyCalender.

 .Description
  This Function pulls CowinSlotsbyCalender information from Cowin APIs.

 .Parameter districtID
  Parameter to provide districtID.

 .Parameter Date
  Optional Paramaeter to Input date.

 .Example
 #To pass multiple districtid to the function
 651,652 | Get-CowinSlotsbyCalender | ft

.Example
 #To find the slots by agelimit 18 and districtid 652
 Get-CowinSlotsbyCalender -districtID 652 | ?{$_.agelimit -eq 18}

.Example
 #To find the slots available for district 652 starting from 10th of the month
  Get-CowinSlotsbyCalender -districtID 652 -Date 10 | ft  

.Example
 #To find the slots by districtname, stateid
 Get-CowinDistrict -DistrictNametoQuery 'delhi' -StateID 9 | Get-CowinSlotsbyCalender -Date 10 | ft 

#>


function Get-CowinSlotsbyCalender
{
	[CmdletBinding()]
    param
    (
        
        [parameter(Mandatory=$true,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1,900)]
        [int]
        $districtID,

        [parameter(Mandatory=$false)]
        [ValidateRange(0,31)]
        [int]
        $Date = (Get-Date -Format "dd")

    )


    Process 
    {       


           
            $results =@()
            $url="https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=$districtID&date=$Date-05-2021"
            #Write-Host "$url"
       Try
            {
            $invokeresults=Invoke-RestMethod -uri $url -ErrorAction Stop
            if (($invokeresults.centers).count -gt 0)
                {

                    foreach($item in $invokeresults.centers)
                    {

                            $Object =              New-Object PSObject -Property @{
                             Name                = $item.name
                             Address             = $item.address
                             CenterID            = $item.'center_id'
                             State               = $item.'state_name'
                             District            = $item.'district_name'
                             FeeType             =$item.'fee_type'
                             SlotsVacant         =$item.sessions.'available_capacity' -join ','
                             Vaccine             =$item.sessions.'vaccine' -join ','
                             Date                =$item.sessions.'date' -join ','
                             AgeLimit            =$item.sessions.'min_age_limit' -join ','
                            }

                            $results += $Object
                   }
            
                   return $results
      } #If ($invokeresults.sessions.centers.count -gt 0) Closing
      else {Write-Warning "No slots Found for DistrictID $districtID and Date $Date, Please check if you have entered correct Date/information !!"}
     } #try closing

     Catch 

     {
      Write-Warning "Unable to Query Covid Gov API for PS Function Get-CowinSlotsbyCalender. `n $($_.exception.message)"
     }
            
    } #Process Closing

    

} #Function Closing
