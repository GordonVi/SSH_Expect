# SSH_Expect
Powershell SSH expect functions

These functions are useful for automating SSH commands to devices from powershell.

## About
I wrote this to help me automate server and switch provisioning.

## Files
- SSH_Expect_Functions.ps1 - A small library of simple functions
- Demo.ps1 - A demo file 

## Necessary edits before running
- You will need to edit *Demo.ps1* to point to your own Linux or whatever SSH server.
- You will need to input some appropriate commands for your SSH target (This demo was targetting a Debian Linux server with vanilla Linux commands)
- I was lazy and put a quick credentials login to obscure my password. You'll see this at the top of the demo file. Edit this to your liking, or make your own flat file for login. The flat file method is recommended for security reasons. Just don't copy your flatfile to the public.
- You will need to install the Posh-SSH Module. - https://www.powershellgallery.com/packages/Posh-SSH

## The Functions

### ssh_linux_command($command)
For sending commands to a Linux server. This depends on the echo command to generate a sentinal/end of line.  
  
**Ex:**

	ssh_linux_command "ping -c 4 google.com"

### ssh_linux_command_display($command)
Same as above
This will display an output in the Powershell terminal

**Ex:**

	ssh_linux_command "ping -c 4 google.com"

### ssh_prompt_command($prompt,$command)
For sending commands to servers that have different prompts.
Devices like switches, BIOS Management for enterprise servers, appliances, etc  
  
**Ex:**

	ssh_prompt_command "$" "ping -c 2 google.com"

**Note:** The $ is usually what shows up as a character on a prompt. This scans for that "$" string. This could easily be a ">","#", or whatever your SSH server uses

### ssh_prompt_command_display($prompt, $command)
Same as above
This will display an output in the Powershell terminal

**Ex:**

	ssh_prompt_command_display "$" "ping -c 2 google.com"

### ssh_expect_command($command, $expect, $answer)
This will send a command and expect a prompt from the command. It will then answer the expected prompt
This will also return 1 (true) or 0 (false)

**Ex:**

	ssh_expect_command "read -p `"User: `" uservar" "User:" "Test1"

**Note:** This is generating an input line in Linux and answering it. This command makes more sense if your running utilities. This specific command only does 1 answer.

### ssh_command($command)
This will send a command.

_Use this with ssh_expect_

### ssh_expect($expect, $answer)
This will send an answer to a waiting prompt.
This is best used in conjunction with SSH_expect_command
This was made to give the ability to provide multiple answers to a single command. (Numerous yes prompts, etc)

**Ex:**

	ssh_command "read -p `"Test: `" testvar; read -p `"Tester: `" testervar; read -p `"Testerx: `" testerxvar"

	ssh_expect "Test" "Test3" | out-null
	ssh_expect "Tester" "Test4" | out-null
	ssh_expect "Testerx" "Test5" | out-null

### ssh_wait($expect)
This will halt your script in with 1 second checks for a string of text you expect to appear.
This is useful for very long commands or scripts that have a "finished" dialogue at the end
This is handy after starting a command with an expect command, then waiting for a line of text to confirm that it is done.

This doesn't have a timeout

**Ex:**

	$SSHStream.writeline("ping -c 4 google.com")
	ssh_wait "min/avg/max/mdev"

Notes: Linux is pinging google.com 4 times. This could be something bigger like 100 times, also. At the end of the command, a final line is written with the string "min/avg/max/mdev". SSH_Wait will scan for that line. When it sees it, it will escape the loop it is in and proceed with the script.
