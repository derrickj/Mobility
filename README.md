# Mobility (for iOS)
This is an iOS version of 
[Mobility for Android](https://github.com/cens/MobilityPhone).
Android Mobility uses gps, wifi,
cell tower info, and accelerometer data to classify a user's activity.
In addition doing activity classification on device, it makes it's data
available to the Ohmage Android client for upload to Ohmage server. 


Since iOS background processing is limited, Mobility will track as much
info as possible, but not attempt classification on device. It will make
it's data available to other apps. The extent to which activity
classification can be done on the server is TBD.


