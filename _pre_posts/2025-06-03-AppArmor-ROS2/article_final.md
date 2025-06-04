# Apparmor- The article I tried not to write.

- when i first started this project AppArmor was not part of it
- I had been using RHEL and Oracle Linux for a few year and I had a basic understanding of SELinux.
- I tried getting ROS2 and Oracle Linux to work together but after spending a few day trying to get them to work and I still had issues
- Then I tried SELinux on Ubuntu and was still running into issues.
- I know either should work but I wasn't not willing to spend the time at this point to get them working
- I know AppArmor worked on Ubuntu and ROS2 and Ubuntu worked will together so i headed in that direction.

## Mandatory Access Control
- Linux has a few different types of file permission that fall into DAC - Discretionary Access Control, ACL - Access Control Lists and MAC - Mandatory Access Control [read more here](https://richard-sebos.github.io/sebostechnology/posts/DAC-ACL-MAC/)
- AppArmor and SELinux falling the MAC catagory but there are some distict difference between
- AppArmor extends DAC, which works on users, by define what programs can do on files and directory

## Why it did not 
- A great example would be the `colcon` command for ROS2, since it build the packages that make the robot run
- `colcon` is needed dev to build code but for security reason, you may only want `colcon` to run while deploying code to UAT or production
- In theory it works but with issues.
- When I deny colcon access to the files in a directory, colcon command started a python program that error on on file permissions so some part of the colcon command ran.
- This lead to a larger list of programs that needed to be added to the policy

## So Is AppArmor the Wrong Tool
- I think AppArmor works and other test I done it work without any issues
- I would call this work as designed but not as expected, in my case
- AppArmor, does not stop a program from running, it stop a program from accessing files
- So it allow the program to run and it would need to handle the errors at the running programs allocation level
- It does it at the all users level
- It is just not the write tool for `colcon` and other tools like it.

## Would I use AppArmor
- Yes, I put AppArmor and Uncomplicated Firewall (UFW) in the same class.
- The work and have their place, and if you have other security layers in front of them their limitations can be covered
- A robot and the controller for it will not have addition security layers since it need to operate and communiticate with the hardware it has.
- At this point, I need to see of Oracle Linux and ROS2 will work together or should I look at getting SELinux and Firewalld working on Ubuntu.
- I would like your suggestion on this.

> Lean more about SELinx [read here]()
