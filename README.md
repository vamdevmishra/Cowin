This Project Contains One Powershell Module Named as Cowin which contains below functions

This Module can be used to Fetch COVID nearest vaccination center and slots availability in India.

More link on below pages regarding India vaccination drive and Open API for Cowin.
https://www.cowin.gov.in/home
https://apisetu.gov.in/public/marketplace/api/cowin

Steps to download and install the module

1. Download the module files Cowin.psd1 and Cowin.psm1
2. Run below command on Powershell Window to import the module

   Import-Module .\Cowin.psd1

3. Below are the functions to consume from this module, here Show-Notification is a helper function to send toast and email notifications. Please use the examples listed in the individual cmdlets to fetch the vaccination slots.

4. In Order to run Get-CowinSlotsByDate and Get-CowinSlotsbyCalender functions, you need to know the StateID and DistrictID, which you can fetch from Get-CowinStateID and Get-CowinDistrict.

Note:
Order to run the cmdlets
Get-CowinStateID -> Get-CowinDistrict -> Get-CowinSlotsByDate -> Get-CowinSlotsbyCalender -> Get-CowinSlotsbyCalender (optional)

CommandType     Name                                               Version    Source                                                                                                                                                                                                                                
Function        Get-CowinDistrict                                  1.0.0      Cowin                                                                                                                                            
Function        Get-CowinSlotsbyCalender                           1.0.0      Cowin                                                                                                                                            
Function        Get-CowinSlotsByDate                               1.0.0      Cowin                                                                                                                                            
Function        Get-CowinSlotsNearMe                               1.0.0      Cowin                                                                                                                                            
Function        Get-CowinStateID                                   1.0.0      Cowin                                                                                                                                            
Function        Show-Notification                                  1.0.0      Cowin   
