From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Fri, 03 Aug 2001 14:54:59 +0000
Subject: [Linux-ia64] Kernel BUG report
Message-Id: <marc-linux-ia64-105590693005999@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I hit this running mkfs on a 8GB, 4X Lion running 4 mkfs processes,
each on an 8-disk "md", with 8 disks on each of 4 Adaptec scsi channels
[each md has 2 disks on each controller], with the boot disk on a separate
adaptec controller; ql12160 unused.

Running the latest 2.4.7 IA64 patches, plus SGI's kernel profiling patches
and the latest 6.20 adaptec driver from Justin Gibbs
(people.freebsd.org/~gibbs/linux).

I had previously run that test with a couple "sync"s running in other
vt logins and it ran (*very* slowly, hence the profiling).

  Kernel BUG at page_alloc.c: 75!
  Unable to handle kernel paging request at virtual address 0000000000000000
  mkfs.ext2[1582]: Oops 11003706212352

This is in __free_pages_ok:
	if (page->mapping)
=>		BUG();

Unfortunatly I didn't write down more info before the machine was rebooted;
looks like I'll have to set up a serial console.


I've also been getting a LOT (100's, not 10's) of these:
  Warning - running *really* short on DMA buffers
which appear to be coming from the SCSI subsystem.


Update: I ran the "test" again, and I got a bunch more "short on DMA
buffers"
messages, and then I got a bunch of lines like:
  Segment 0xe000000228eb7840, blocks 2, addr 0x228eb13ff
followed by:
  Kernel panic:  Ththththaats all folks.  Too dangerous to continue.


Kevin

