From: Einar Saltnes <eisa@scali.no>
Date: Fri, 13 Oct 2000 09:55:10 +0000
Subject: [Linux-ia64] clock stops on test9
Message-Id: <marc-linux-ia64-105590678205567@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
I have upgraded a dual Itanium Workstation SDV from A3-stepping/BIOS 50
to B1-stepping/BIOS 60. After getting the upgraded box up and running
stable (had to decrease the FSB speed or move memory as pointed out by
Intel), I had some hard time trying to get linux up and run.
RedHat developer distro 0825 did not install. When taking out one cpu I
could get some further in the installation from the CD, but not finish
it successfully.
To install a newer kernel, I had to swap the disk to my UP Itanium
Workstation SDV A2-stepping/BIOS 50 which has been running stable, more
or less, on the 0829 kernel update from RedHat. Then compile a new
kernel
and swap disks again.
I am now running the test9 kernel on the dual B1-stepping Itanium and it
seems to run stable, more or less. I have also installed
modutils-2.3.17, which was pointed out on this list.

However, there are some problems with the system clock. The BIOS clock
seems to run OK, but in linux the clock seems to stop after some random
time. When using "date", time stands still after some random time! This
gives me some trouble using other utilities e.g. ping and even shutdown.
This shows only on the dual B1-stepping box and not the UP A2-stepping
box. It can run OK for a few minutes or for some hours.
Anyone got a clue?

Which configuration settings should I use regarding the A-stepping /
A1-stepping / B-stepping / B1-stepping settings in menuconfig for my two
Itanium boxes (see below)?
What about the settings if I change back to Dual A3-stepping / BIOS 50 ?
(So far I have been looking at H.J.Lu's settings which was posted on Sep
08)


Workstation SDV #1:
- UP A2-stepping
- Bios 50
- 1GB memory
- QLA1280 scsi-adapter
- SCSI-disk
- LS-120 floppy drive
- IDE CD-ROM
- ATI Rage128 PCI graphics adapter
- linux-2.4.0-test9 UP configuration

Workstation SDV #2:
- Dual B1-stepping
- BIOS 60
- 1GB memory
- QLA1280 scsi-adapter
- SCSI-disk
- LS-120 floppy drive
- IDE CD-ROM
- ATI Rage128 PCI graphics adapter
- linux-2.4.0-test9 SMP configuration

BTW, when talking about BigSurs and Lions how can I tell them apart? It
would be nice to know when something on this list applies to my Itanium
boxes.

Thanks,
Einar
-- 
| Einar Saltnes          |         Scali AS         |
| mailto:eisa@scali.no   |   http://www.scali.com   |
| Phone:+47 22 62 89 50  |  Scalable Linux Systems  |
| Fax  :+47 22 62 89 51  |      and Technology      |

