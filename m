From: Martin Wilck <Martin.Wilck@fujitsu-siemens.com>
Date: Fri, 18 May 2001 16:50:44 +0000
Subject: [Linux-ia64] GUID filesystem+device identification ?
Message-Id: <marc-linux-ia64-105590693005620@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,

Has anybody yet thought about the possibility to use
a mechanism like devfs for identifying devices and file systems
by their GUID? This would be a major improvement over Linux's current
approach of identifying devices, particularly disk drives.

In principle, it would be possible to change controllers and
disks arbitrarily and still maintain a valid file system in which
all devices and sub-file systems would be identified by ther GUIDs
(think of the device in fstab specified by GUID instead of /dev/sda3
or whatever).

I think something like this could well coexist with devfs in its current
implementation, e.g. by a collection of softlinks , something like

/dev/guid/disk/[DISK_GUID]->/dev/scsi/host1/bus0/target2/lun0
/dev/guid/partitions/[PARTITION_GUID]->(you guess).

where these links would be auto-generated when a driver encounters
a disk and and the partition table is analyzed.

Links for other devices could of course also exist in /dev/guid,
although I think disks and parttions give most benefit.

The approach above would allow entries like

/dev/[PARTITION_GUID] /usr ext2 defaults 2 1

in fstab, so no need to change fstab if controllers or disks
are added/removed in a system.

Unlike the "filesystem label" approach, this would work with any
filesystem type, and even for entire disks and other devices.

Is anybody working on something like this, or does it even exist
already?
If no, what is your opinion on its usefulness?

Regards,
Martin

-- 
Martin Wilck     <Martin.Wilck@fujitsu-siemens.com>
FSC EP PS DS1, Paderborn      Tel. +49 5251 8 15113




