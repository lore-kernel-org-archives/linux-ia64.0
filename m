From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 06 Mar 2003 23:27:32 +0000
Subject: Re: [Linux-ia64] ia64 rwsem using atomic primitive
Message-Id: <marc-linux-ia64-105590709805993@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I have converted rw semaphore from current generic spin_lock implementation to use architecture specific atomic operation on ia64.  This new scheme speeds up all the semaphore operations in the fast path with atomic instruction and fall back to a heavy function when there are read/write contention.  I've also taken some raw measurement how fast it improves.  The most significant gain comes from parallel reader lock acquire/release which has around 6.6X speed up with the new version.  Here is a patch against 2.4.20.

I applied this patch to 2.4.  I also picked up David's tweaks to improve
the optimization of ia64_fetch_and_add, including the move of that
function and related ones to intrinsics.h.

Bjorn


