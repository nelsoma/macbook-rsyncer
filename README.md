# macbook-rsyncer
This script will execute an rsync only when on a specific wifi connection, and when connected to power.

## Usage 
Executing this script while passing it a source directory (or file), a destination dir (or file) will attempt an `rsync --archive` between them. 
It also takes a list of wifi SSID's (a comma seperated list, no whitespace) that are viewed as OK.

What I do is run this as a cronjob once a day at 12:30 because that is when I'm likely to be at lunch with my macbook plugged in on my desk.

```shell
$ ./rsyncr.sh -s ~/real-files/ -d ~/backup -w homewifi,workwifi,otherwifi
```
or 

```shell
30 12 * * 1-5 ~/rsyncr.sh -s ~/real-files/ -d ~/backup -w homewifi,workwifi,otherwifi
```

## Ok, but why?

Yeah, so I wanted to copy some locally stored data to a Google Drive syncing directory. But I didn't want to do this while I was on a public wifi or on my tethered phone, and while I was doing that I thought it might as well check to see if it was on power.

## Notes

Commands this relies on:

```shell
$ pmset -g batt
```

Which outputs something like:

> Now drawing from 'Battery Power'
> 
>  -InternalBattery-0 (id=3539043)	82%; discharging; 4:08 remaining present: true

or

> Now drawing from 'AC Power'
> 
>  -InternalBattery-0 (id=3539043)	82%; AC attached; not charging present: true


usefully telling where we are drawing power from. I'm unsure if there are more states than 'Battery Power' or 'AC Power'.

The other useful thing here is this command:

```
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}'
```

Which rips out the current SSID. What happens on a wired ethernet connection? No idea. This script certainly won't work.