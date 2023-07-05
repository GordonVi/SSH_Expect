function global:ssh_wait($expect){

		
		$expectVar = 0
		$lines=@()
		$total=@()
		do {

			do {} until ($SSHStream.dataavailable)
		
			$lines = foreach ($line in $($SSHStream.read()).split("`n")) {if ($line -like "*$expect*") {$expectvar=1}}
			
		} until ($expectvar -eq 1)
		
}

function global:ssh_expect($expect, $answer){

		
		do {} until ($SSHStream.dataavailable)
		sleep -milli 250

		$expectvar=0
		$lines=@()
		$total=@()
		do {

			
			if ($SSHStream.dataavailable) {
				
				$z = $SSHStream.Read()
				$y = $z.split("`n")
				$x = $y[$y.count-1]
				#foreach ($x in $y) {
					if ($x -like "*$expect*") {$SSHStream.writeline($answer) ; $expectvar=1}
				#}
			}



		} until ($expectvar -eq 1 -or $SSHStream.dataavailable -eq $false)
		
		if ($expectvar -eq 0) {return 0} else {return 1}
		
}

function global:ssh_expect_command($command, $expect, $answer){

		
		do {$SSHStream.read() | out-null} until ($SSHStream.dataavailable -eq $false)
		$SSHStream.writeline($command)
		do {} until ($SSHStream.dataavailable)
		sleep -milli 250

		$expectvar=0
		$lines=@()
		$total=@()
		do {

			
			if ($SSHStream.dataavailable) {
				
				$y = $($SSHStream.Read()).split("`n")
				foreach ($x in $y) {
					if ($x -like "*$expect*" -and $x -notlike "*$command*") {$SSHStream.writeline($answer) ; $expectvar=1}
				}
			}



		} until ($expectvar -eq 1 -or $SSHStream.dataavailable -eq $false)

		if ($expectvar -eq 0) {return 0} else {return 1}
		
}

function global:ssh_prompt_command($prompt,$command){

		
		do {$SSHStream.read() | out-null} until ($SSHStream.dataavailable -eq $false)
		$SSHStream.writeline($command)

		$lines=@()
		$total=@()
		do {

			sleep -milli 500
			do {} until ($SSHStream.dataavailable)
		
			$lines = foreach ($line in $($SSHStream.read()).split("`n")) {if ($line -ne "") {$line}}
			$total += $lines
			
		} until ($lines[$lines.count-1] -like "*$prompt*")
		
		return $total
		
}

function global:ssh_prompt_command_display($prompt, $command){

		$StopWatch = New-Object System.Diagnostics.Stopwatch
		$StopWatch.Start()
		write-host -foregroundcolor yellow "$prompt > $command"
		$lines=$(ssh_prompt_command $prompt $command)
		$StopWatch.Stop()

		write-host -foregroundcolor green "Time: $($StopWatch.Elapsed)"
		foreach ($line in $lines) {write-host -foregroundcolor cyan $line}
	
}

function global:ssh_linux_command($command){

		$sentinal = "UniqueScriptSentinal"
		$line=""
		$lines = @()

		do {$SSHStream.read() | out-null} until ($SSHStream.dataavailable -eq $false)
		$SSHStream.writeline($command)
		$SSHStream.writeline("echo $sentinal")
		do {$line = $SSHStream.ReadLine(); if ($line -notlike "*$sentinal*" -and $line -notlike "*$command*") {$lines += "$line"}} while ($line -notlike "*$sentinal*")

		return $lines
}


function global:ssh_linux_command_display($command){

		$StopWatch = New-Object System.Diagnostics.Stopwatch
		$StopWatch.Start()
		write-host -foregroundcolor yellow $command
		$lines=$(ssh_linux_command($command))
		$StopWatch.Stop()

		write-host -foregroundcolor green "Time: $($StopWatch.Elapsed)"
		foreach ($line in $lines) {write-host -foregroundcolor cyan $line}
	
}

function global:ssh_command($command){

		do {$SSHStream.read() | out-null} until ($SSHStream.dataavailable -eq $false)
		$SSHStream.writeline($command)
}