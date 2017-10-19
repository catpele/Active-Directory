##################################################
# Imports users from a CSV into Active Directory #
##################################################

# Edit the path to match your CSV location

$path = <path to csv>
$users = Import-Csv $path

# Iterate through the CSV to find the relevant fields

ForEach ($user in $users) {
	$SAM = $user.logon
	$company = $user.company
	$dept = $user.team
	$title = $user.title
	$manager = $user.manager
	$email = $user.email

# Import
	Set-ADUser -Identity $SAM -Company $company -Department $dept -Title $title -Manager $manager -Email $email
}
