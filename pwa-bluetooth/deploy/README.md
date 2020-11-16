# Hackserver
This is a very simple web application which can serve as a base for then M&F hackaton projects.
The backend is a node application with an express web server which serves the static files in the public directory. Additionally, it starts a websocket server which is able to synchronize a data model between several clients.

## Server

To build and run the server, nodejs has to be installed. To run the server, type

```
npm install
node server.js
```

The server will run locally and the page can be loaded under the following address:
```
http:\\localhost:3000
```

## Deployment on Azure

You will need an azure account with M&F Engineering.
To deploy the solution to azure, the following preparations have to be made locally:

* Install Azure CLI from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
* Edit script ```deployall.ps1``` and chose your own $webappname, $gitUser and $gitPW
* Open a windows powershell in the directory of the file ```deployall.ps1```
* Run the script with ```.\deployall.ps1``` 

If you get an error message from Powershell that the script is not signed, do the following:

* Open powershell as Administrator
* Execute the following command: ```set-executionpolicy unrestricted```

