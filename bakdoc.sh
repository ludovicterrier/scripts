 rsync -av --progress --stats --delete --exclude="Parallels" --exclude=".parallels-vm-directory" --exclude=".git" --exclude=".svn" --filter "- *.dng" --filter "- Virtual Machines.localized" --filter "- .DS_Store" --filter "- *.iso" /Users/ludo/Documents/ --rsync-path=/usr/syno/bin/rsync ludo@nas.ludovicterrier.fr:/volume1/documents/macbook
