Import-Module Posh-SSH
. .\SSH_Expect_Functions

# SSH Credentials
$site = "virasawmi.com"
$user = "username"
$password = ConvertTo-SecureString "Password" -AsPlainText -Force

$credential = New-Object PSCredential ($user, $password)

# Save to flat file
# $credential |  Export-Clixml -Path .\fakesite.com.xml

# Load from flat file - This is to obscure passwords from git
$credential = Import-Clixml -Path fakesite.com.xml

# -------------------------------


# create session on this client
$Session = New-SSHSession -ComputerName $site -Credential $credential -AcceptKey


# -----------------------------------------------

if ($session.host.length -gt 0) {
	
	# connect to host
	# Note: Do not change this variable name. The Included Function require this name as to access it globally.
	$SSHStream = New-SSHShellStream -Index $Session.SessionId

# -------------------------------

	$SSHStream.read() | Out-Null # Clear the SSH read buffer. Usually, servers have ASCII art as a server header.

	# Demo section

		ssh_linux_command_display "ping -c 2 google.com"
		ssh_linux_command_display "traceroute google.com"

		ssh_prompt_command_display "$" "ping -c 2 google.com"

	"Starting Expect Commands..."

		ssh_expect_command "read -p `"User: `" uservar" "User:" "Test1" | out-null
		ssh_expect_command "read -p `"Pass: `" passvar" "Pass:" "Test2" | out-null
		ssh_expect_command "read -p `"Test: `" testvar; read -p `"Tester: `" testervar; read -p `"Testerx: `" testerxvar" "Test:" "Test3" | out-null

		ssh_expect "Tester" "Test4" | out-null
		ssh_expect "Testerx" "Test5" | out-null

	"Ending Expect Commands..."
	
	"Starting ping wait..."
	
		$SSHStream.writeline("ping -c 4 google.com")
		ssh_wait "min/avg/max/mdev"
		
	"Ending ping wait..."
	

		sleep 1 # Powershell is faster than the SSH client's refresh. This is to give SSH some time to catch up and update the SSH buffer.
		
		ssh_linux_command_display "echo uservar = `$uservar"
		ssh_linux_command_display "echo passvar = `$passvar"
		ssh_linux_command_display "echo testvar = `$testvar"
		ssh_linux_command_display "echo testervar = `$testervar"
		ssh_linux_command_display "echo testerxvar = `$testerxvar"

		
# -------------------------------

	# close and remove SSH session
	$SSHStream.Close()
	Remove-SSHSession -SSHSession $session | Out-Null
	
} else {write-host -foregroundcolor yellow "no connection"}


