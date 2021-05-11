function Get-CowinDistrict
{

<#
 .Synopsis
  Get the CowinDistrictID.

 .Description
  This Function pulls CowinDistrictID information from Cowin APIs.

 .Parameter StateID
  Need StateID of the State.

 .Parameter DistrictNametoQuery
  Optional Paramaeter to Query DistrictID by DistrictName.

 .Example 
     Get-CowinDistrict -StateID 34
       # To find all districts in stateid 34
   

 .Example

      Get-CowinDistrict -DistrictNametoQuery 'Delhi' -stateid 9 | ft
       # To find a particular state and it's ID
    

 .Example
    Get-CowinStateID -StateNametoQuery 'uttar' | Get-CowinDistrict | ft

 .Example
    10,11,12 | Get-CowinDistrict | ft
    #To pass multiple district IDs, propertybyvalue

 .Example
     Get-CowinStateID | Get-CowinDistrict | ft
     #To pass multiple district IDs, propertybyname
#>

	[CmdletBinding()]
    param
    (
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int[]]$StateID,
        [parameter(Mandatory=$false)]
        [String]
        $DistrictNametoQuery


    )


    Process 
    {
          $results =@()

         $url="https://cdn-api.co-vin.in/api/v2/admin/location/districts/$StateID"
         Try
         {
            $invokeresults=Invoke-RestMethod -uri $url -ErrorAction Stop
     

         if ($invokeresults.districts.Count -gt 0)
                                                                         {

         foreach($item in $invokeresults.districts)
                        {

                         $Object =           New-Object PSObject  -Property  @{
                         DistrictName        = $item.'district_name'
                         DistrictID          = $item.'district_id'

                         }

                         $results += $Object

                }
            if($DistrictNametoQuery)
                {
                 $results | ? {$_.DistrictName -like "*$DistrictNametoQuery*"} 
                }

            else
                    {
                    $results | select Districtid,Districtname 
                    }
    } #if $invokeresults.districts.Count -gt 0
        else 
        {
            Write-Warning "No Districts Found, Please check if you have entered correct StateID"
        }


                } #try closing

                Catch

                    {
             
                     Write-Warning "Unable to Query Covid Gov API for PS Function Get-CowinDistrict. `n $($_.exception.message)" 

                    } #catch closing


  
    } #end Process
} #end function