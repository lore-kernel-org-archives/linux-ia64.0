From: "Miller, Mike (OS Dev)" <Mike.Miller@COMPAQ.com>
Date: Tue, 15 May 2001 19:00:17 +0000
Subject: [Linux-ia64] System hang
Message-Id: <marc-linux-ia64-105590693005584@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sorry if this not the right forum for this problem.
I have encountered a system hang when running heavy I/O. It only occurs when
running MP and >4GB RAM. I have seen this under the 2.4.3 and 2.4.4 kernels.
Current setup is 2.4.4 with the 010508 ia64 diff patch and kdb applied. The
system has 2 C0 processors and 8GB of memory. The test is very simple, just
using cpio -p to copy files. It causes a machine check within 5 minutes that
locks up the boot strap processor. We've looked at HW and cannot pinpoint a
HW failure. This has been reproduced on several different systems including
one with B3 processors.
After stripping out all the extraneous drivers from the kernel including
USB, storage drivers not in use, WAN, etc. the problem has gone away. I am
now trying to add drivers back one at a time to isolate the problem w/o any
luck so far. 
Has anyone else observed a similiar hang? The outward symptoms are all I/O
stops and the keyboard does not respond. The system must be power cycled.

Thanks,
mikem

