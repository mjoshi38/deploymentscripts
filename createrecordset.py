#############################################################################################
####This script should only be used to create Alias Record Set in AWS Route53 using boto3####
#############################################################################################

import boto3, botocore, sys , os

route53=boto3.client('route53')

global Src_Host_Zone_Id, Des_Host_Zone_Id, Dest_DNS_Name, Target_Health, File_Name

def new_record_set(new_name):
        try:
               global Src_Host_Zone_Id, Des_Host_Zone_Id, Dest_DNS_Name, Target_Health
               response=route53.change_resource_record_sets(
           HostedZoneId=Src_Host_Zone_Id,
           ChangeBatch={
                       'Comment': 'Creating a new Resource Record Set',
                       'Changes': [
                   {
                               'Action': 'CREATE',
                               'ResourceRecordSet': {
                             'Name': new_name,
                             'Type': 'A',
                           'AliasTarget': {
                                       'HostedZoneId': Des_Host_Zone_Id,
                                       'DNSName': Dest_DNS_Name,
                                       'EvaluateTargetHealth': Target_Health
                        },
                        }
                },
                ]
        }
        )
               print(("Record Set '{}' created successfully" .format(new_name)))
        except Exception:
               print(("Record Set '{}' creation failed" .format(new_name)))

def check_file():
        global File_Name
        if (os.path.isfile(File_Name)):
               if(os.stat(File_Name).st_size == 0):
                     print("File is Empty. Check the file and try again.")
                     sys.exit(1)
               else:
                     my_file=open(File_Name, "r")
                     if my_file.mode == "r":
                          for line in my_file:
                              Newdomain='{}'.format(line).rstrip()
                              new_record_set(Newdomain)
                     else:
                          print("Unable to open file in read only mode.Exiting...")
                          sys.exit(1)
                     my_file.close()
        elif (os.path.isdir(File_Name)):
               print("'{}' is not a file, it's a directory. Exiting..." .format(File_Name))
               sys.exit(1)
        else:
                print("'{}' is not a regular file. Check the file type and try again. Exiting..." .format(File_Name))
                sys.exit(1)


def validate_input():
        global Src_Host_Zone_Id, Des_Host_Zone_Id, Dest_DNS_Name, Target_Health, File_Name
        if not os.path.exists(File_Name):
            print("File doesn't exist. Check filename and try again. Exiting...")
            sys.exit(1)

        if (len(Src_Host_Zone_Id.strip()) == 0):
               print("Hosted Zone ID cannot be empty. Try again")
               sys.exit(1)
        else:
               try:
                     response=route53.get_hosted_zone(
                        Id=Src_Host_Zone_Id
                       )
               except:
                     print(("There isn't any Hosted Zone with the ID '{}'. Try again" .format(Src_Host_Zone_Id)))
                     sys.exit(1)

        if (len(Des_Host_Zone_Id.strip()) == 0):
               Des_Host_Zone_Id=Src_Host_Zone_Id

        if (len(Dest_DNS_Name.strip()) == 0):
               print("DNS Name cann't be empty. Try again")
               sys.exit(1)

        if (Target_Health.lower() == 'true'):
               Target_Health=True
               check_file()
        elif(Target_Health.lower() == 'false'):
               Target_Health=False
               check_file()
        else:
               print("Evaluate Target Health value should be (True/False). Try Again")
               sys.exit(1)

def user_input():
    global Src_Host_Zone_Id, Des_Host_Zone_Id, Dest_DNS_Name, Target_Health, File_Name
    File_Name=input("Enter file name ::")
    Src_Host_Zone_Id=input("Enter Hosted Zone Id where you want to create the Record Set ::")
    Des_Host_Zone_Id=input("Enter Hosted Zone Id of Destination DNS Name - Optional. (Required while creating Alias to point ELB, etc) ::")
    Dest_DNS_Name=input("Enter DNS Name to point the Record Set ::")
    Target_Health=input("Enter Evaluate Target Health either True or False ::")
    validate_input()

def main():
    user_input()

if __name__ =="__main__":
    main()
