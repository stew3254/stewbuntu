# Stewbuntu

If your username is stew3254, then this is the right distribution for you. All the configurations will be to your taste, and the defaults will be sane. You will appreciate the work the developers have done to make this optimal for your experience.

For everyone else, you may be able to benefit from such an experiment. If you have any suggestions, feel free to add a PR. If you have any complaints in the desktop configuration, feel free to send them to /dev/null :)

To my knowledge, this does not work without root privileges. Even when using fakechroot and fakeroot. So, I recommend building it within a VM. To spin up a quick vm:
* `lxd init --auto # if not already initialized`
* `lxc launch ubuntu:jammy stewbuntu --vm`
* `lxc shell stewbuntu`
