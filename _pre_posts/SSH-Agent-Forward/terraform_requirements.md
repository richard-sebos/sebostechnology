# Forward Agent Project

## Goal
- Create a local SSH Agent forward to a Google Cloud project (GCP) VM as a jump box.  
- I would then be able to use that forwarding agent to other project VMs

## High Level Objects needed

## Local MacBookPro M4
    - used as the device offering the Forwarding Agent
    - will have .ssh/config that referrences the servers in the Forward Agent process
    - this is being used a client machine to access the GCP VMs

### Jump VM 
- A new GCP VM is needeed to act like a jump box.
    - This is be an Oracle 9 Server
    - This will be used to access more than one GCP VMs
- It should have two users
    - richard 
        - restricted user used to log to server
        - Used to coonect to other cloud servers
        - default shell is rbash
        - $PATH is restricted to ~/.bin
        - ~/.bin has commands limited to
        - su 
        - ls
        - cd
    - admin_richard 
        - full access sudo user
        - does not have ssh access

### Project VMs
- There could me one or more project VMs needed that the Jump VM would have access to
    - These are the servers the project needed
    - The MacBookPro would access these server using the Forward Agent and the Jump VM
- It should have two users
    - richard 
        - restricted user used to log to server
        - Used to coonect to other cloud servers
        - default shell is rbash
        - $PATH is restricted to ~/.bin
        - ~/.bin has commands limited to
        - su 
        - ls
        - cd
    - admin_richard 
        - full access sudo user
        - does not have ssh access

## Actions Needed
- Use the Forwarding Agent to log onto Project VM
- Deploy GitHub code with GitHub Auth Keys on the MacBookPro