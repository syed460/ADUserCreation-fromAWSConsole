# Create New Users from AWS Portal on the AD server

Using:
    AWS EC2-Serial console

Using Powershell Script which we keep inside the server.

## Variables are stored in the var.json file

    $bucketpath = "<>"

-----------------------------------
Steps to perform the user creation:

Step 1:
	Create CSV File with the user details as below,
    username,discription,email,password,memberof1,memberof2,memberof3
![csvfilepic](https://github.com/syed460/ADUserCreation-fromAWSConsole/blob/master/csvfilepic.png "csvfile")

Step 2:
	Upload the file into S3 bucket > under the folder
	

Step 3:
	Navigate to EC2 > Serial console 
	

Step 4:
	Provide the Absolute patch of the script with the four arguments.
	
    1. file.csv (csv file name with its extention)
    2. YourUsername (for AD authentication)
    3. YourPassword (for AD authentication)
    4. yes (to proceed to user creation as confirmation)

	C:\<path>\main.ps1 -csvfilename file.csv -user YourUsername -password YourPassword -continue yes

Step 5:
    Take Screenshot of the output for artifacts

-------------------
