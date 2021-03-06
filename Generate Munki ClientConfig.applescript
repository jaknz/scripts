on run
	
	-- this repeat loop prevents empty strings from being submitted for the package name value
	set q to 0
	repeat while q is 0
		set result to text returned of (display dialog "Enter the DNS name for your Munki server:" default answer "munki.local")
		if result is not "" then
			set munkiserver to result
			set q to 1
		end if
	end repeat
	-- this repeat loop prevents empty strings from being submitted for the package identifier value
	set q to 0
	repeat while q is 0
		set result to text returned of (display dialog "Enter a Client Identifier:" default answer "baseline")
		if result is not "" then
			set manifest to result
			set q to 1
		end if
	end repeat
	
	set pkgname to "Client Config for " & munkiserver & " " & manifest
	
	-- this repeat loop prevents empty strings from being submitted for the version identifier value
	set pkgvers to (do shell script "date +%Y.%m.%d")
	
	set q to 0
	repeat while q is 0
		set result to text returned of (display dialog "Enter a Version Identifier:" default answer pkgvers)
		if result is not "" then
			set pkgvers to result
			set q to 1
		end if
	end repeat
	
	-- Write the script
	set postinstall_file to (":tmp:postinstall")
	set postinstall_contents to "#!/bin/bash

/usr/bin/defaults write /Library/Preferences/ManagedInstalls.plist SoftwareRepoURL http://" & munkiserver & "/munki_repo" & "
/usr/bin/defaults write /Library/Preferences/ManagedInstalls.plist ClientIdentifier " & manifest & "

chown root:wheel /Library/Preferences/ManagedInstalls.plist
chmod u+rw-x,go+r-wx /Library/Preferences/ManagedInstalls.plist

exit 0"
	
	try
		set the target_file to the postinstall_file as string
		set the open_target_file to open for access file target_file with write permission
		set eof of the open_target_file to 0
		write postinstall_contents to the open_target_file starting at eof
		close access the open_target_file
	on error
		try
			close access file target_file
		end try
		display alert "Some sort of error"
	end try
	
	-- Set the postinstall script to be executable
	
	do shell script "chmod a+x /tmp/postinstall" -- with administrator privileges
	
	-- Remove any existing build directories that have the same name as the new payload-free package
	
	do shell script "rm -rf /tmp/" & quoted form of pkgname & "/" -- with administrator privileges
	
	-- Create the build directories for the payload-free package
	
	do shell script "mkdir /tmp/" & quoted form of pkgname & "" -- with administrator privileges
	do shell script "mkdir /tmp/" & quoted form of pkgname & "/scripts" -- with administrator privileges
	do shell script "mkdir /tmp/" & quoted form of pkgname & "/nopayload" -- with administrator privileges
	
	-- Move the postinstall script into the correct build directory
	
	do shell script "mv /tmp/postinstall /tmp/" & quoted form of pkgname & "/scripts" -- with administrator privileges
	
	-- Build the payload-free package
	
	do shell script "pkgbuild --identifier nz.co.tts.munki.config" & " --version " & quoted form of pkgvers & " --root /tmp/" & quoted form of pkgname & "/nopayload --scripts /tmp/" & quoted form of pkgname & "/scripts /tmp/" & quoted form of pkgname & "/" & quoted form of pkgname & ".pkg" -- with administrator privileges
	
	-- Display dialog that the payload-free package has been created
	
	display alert ((pkgname) as string) & ".pkg has been created."
	
	-- Open a new Finder window that shows the new package
	
	do shell script "open /tmp/" & quoted form of pkgname & ""
	
	--return input
	return
end run