param (
 [String]$func=""
 )

# Azure deployment script for windows power shell and Azure CLI
# (C) 2018 by Reto Bättig

# Settings for each team of Hackaton (change to unique name)
$webappname = "HackserverPWABluetooth"
$gitUser = "Team1User"
$gitPW = "Te@m1U5er"

# Settings fixed for MF Hackaton 2018
$webappdir="NodeServer"
$resourceGroupName = "flexiotdemo"
$AppServicePlan = "PWABluetoothServicePlan"
$location = "westeurope"

# -------------
# Main script
# -------------
function main() {
	Write "Logging in to Azure..."
	Login
	Deploy
}

# Deploy(): Deploys the whole solution from scratch using the settings at the
# begin of the file
function Deploy() {

	$a = GroupExists $resourceGroupName
	if ($a -eq "True") {
		echo "Group already exists, continuing"
	} else {
		echo "Creating resource group $resourceGroupName"
		az group create -l $location -n $resourceGroupName
	}

	$a = AppServiceExists $AppServicePlan $resourceGroupName
	if ($a -eq "True") {
		echo "App Service Plan already exists, continuing"
	} else {
		echo "Creating App Service plan $AppServicePlan in 'FREE' tier."
		az appservice plan create --name $AppServicePlan --resource-group $resourceGroupName --sku FREE
	}

	$a = WebAppExists $webappname $resourceGroupName
	if ($a -eq "True") {
		echo "Web App already exists, continuing"
	} else {
		echo "Create web app $webappname"
		az webapp create --name $webappname --resource-group $resourceGroupName --plan $AppServicePlan
	}

	echo "Enable web sockets on web app $webappname"
	az webapp config set --web-sockets-enabled true -g $resourceGroupName -n $webappname

	# Set up user name + password for git and ftp
	az webapp deployment user set --user-name $gitUser --password $gitPW

	# Set up local git and get url
	$giturl=(az webapp deployment source config-local-git -g $resourceGroupName -n $webappname --output tsv)
	$portpos=$giturl.IndexOf(":443")
	if ($portpos -eq -1) {
		echo "Portnumber not found in Git URL $giturl, adding it to `$giturl2..."
		$giturl2=$giturl.Insert($giturl.IndexOf($webappname+".git")-1, ":443")
		echo "`$giturl2 = $giturl2"
	}  else {
		echo "Portnumber found in Git URL $giturl"
	}

	InstallWebApp $webappdir $giturl $giturl2

	# Delete settings.txt
	# Settings.txt will contain all the required infos for applications, connections etc.
	rm settings.txt 2>&1 | Out-Null
	echo "# Settings of your Application" >> settings.txt
	echo "`$webappname = $webappname" >> settings.txt
	echo "`$gitUser = $gitUser" >> settings.txt
	echo "`$gitPW = $gitPW" >> settings.txt
	echo "`$webappdir = $webappdir" >> settings.txt
	echo "`$resourceGroupName = $resourceGroupName" >> settings.txt
	echo "`$AppServicePlan = $AppServicePlan" >> settings.txt
	echo "`$giturl = $giturl" >> settings.txt
	echo "`$giturl2 = $giturl2" >> settings.txt

	$m="http://" + $webappname + ".azurewebsites.net"
	echo "Finished!!! App URL = $m"
	echo "`$AppUrl = $m" >>settings.txt
}

function InstallWebApp($webappdir, $giturl, $giturl2) {
	cd $webappdir
	rmdir -r -Force .git 2>&1 | Out-Null
	git init
	git add --all
	git commit -am "Initial git setup"
	git remote remove webapp 2>&1 | Out-Null
	git remote add webapp $giturl
	git push -f webapp master
	if ($LASTEXITCODE -eq 0) {
		echo "Successfully pushed app"
	} else {
		echo "Error pushing app, trying alterate git URL: $giturl2"
		git remote remove webapp 2>&1 | Out-Null
		git remote add webapp $giturl2
		git push -f webapp master
	}
	cd ..
}

# GroupExists($Group): Returns "True" if group already exists
function GroupExists($Group){
	$exists=(az group exists -n $Group)
	return ($exists -eq "true")
}

# AppServiceExists($Service): Returns "True" if app service already exists
function AppServiceExists($Service, $resourceGroupName){
	$exists=(az appservice plan show --resource-group $resourceGroupName --name $AppServicePlan)
	return ($exists -contains "{")
}

# WebAppExists($App): Returns "True" if app already exists
function WebAppExists($App, $resourceGroupName){
	$exists=(az webapp show -n $App --resource-group $resourceGroupName)
	return ($exists -contains "{")
}

# Login(): Tries to login to azure if it's not already done
function login() {
	if (-Not (az account show)) {
		echo "Logging in first..."
		az login | out-null
	}
	if (-Not (az account show)) {
		echo "aborting. could not login to azure"
		exit 1
	}
	return "OK"
}

#-------------------------------------------------
# Call main script
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
main
