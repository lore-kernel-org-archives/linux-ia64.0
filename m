From: hiren_mehta@agilent.com
Date: Wed, 02 May 2001 18:27:07 +0000
Subject: [Linux-ia64] problem with scsi/2.4.2 kernel : help
Message-Id: <marc-linux-ia64-105590693005511@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi List,

I am running a couple of dd processes on the scsi drives
on ia64 running 2.4.2 kernel.

e.g.
while [ 1 ]; do
dd if=/dev/zero of=/dev/sdb1 bs24 count%000000
done &
while [ 1 ] ; do
dd if=/dev/zero of=/dev/sdb2 bs24 count%000000
done &
while [ 1 ] ; do
dd if=/dev/zero of=/dev/sdb3 bs24 count%000000
done &


What I have observed is whenever one of the dd processes completes
and starts another process ( because of while [ 1 ] loop), the system
freezez. I have no idea what is going on. 

In fact I tried this on ia32 system as well. On ia32, I see lot of delay
before I see any activity on the disk and during that time system freezes
and I cannot do any thing. Well, on ia32 finally the system comes back up.
But on ia64 the delay is very huge and sometimes the system does not
come back up even after many hours (even after leaving the system
overnight).

Has anybody seen this problem ? Does anybody know what the problem is ?
I need to have solution for this problem ASAP. Please help me out.

Regards,
-hiren
hiren_mehta@agilent.com

