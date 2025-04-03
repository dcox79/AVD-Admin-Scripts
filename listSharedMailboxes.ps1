#If the script errors out open powershell as admin and use the command below to import required module. 
# Import-Module ExchangeOnlineManagement

#Mailbox Script is not required to run as an admin

#Replace my username with yours 
Connect-ExchangeOnline -UserPrincipalName dcoxada@sterlingbank.com

#Uncomment to view mailboxes and/or shared mailboxes user has full access too.
#Get-Mailbox -RecipientTypeDetails UserMailbox,SharedMailbox -ResultSize Unlimited | Get-MailboxPermission -User bevans
#Uncomment to view shared mailboxes user has Send As access too.
Get-Mailbox -RecipientTypeDetails SharedMailbox | Get-RecipientPermission -Trustee bevans
#Uncomment to view shared mailboxes user has Send on behalf of access to
#Get-Mailbox -RecipientTypeDetails SharedMailbox | ? {$_.GrantSendOnBehalfTo -match "bevsan"}