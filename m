From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sat, 27 Nov 2004 00:27:09 +0000
Subject: ia64 emulator or test machine available
Message-Id: <41A7C9DD.20303@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I have been doing some work in the area of page table lock reduction
in collaboration with Christoph Lameter. The main aim of this is to
improve multi-threaded page fault performance, but may also benefit
other areas, like multi threded futex performance, and page reclaim.

I have working implementations on i386 and x86-64, and now I would like
to get an ia64 version running. For two reasons: first, SGI is pushing
most of the work in this area, obviously for their ia64 systems;

second, ia64's implementation of pte access faults in software means
there is a possibility to implement mutual exclusion for pte access with
pte lock bits rather than cmpxchg, and with no downside. pte lock bits
may prove to be more scalable than cmpxchg in some areas.

With the help of Keith and Christoph, we have a version that is close
to booting - however I can't ask or expect them to debug my bugs. So if
anyone is interested in giving me access to an emulator or (preferably)
machine with serial console and power access that boots recent 2.6
kernels then I would be much obliged.

I wouldn't require anything fancy, nor for (hopefully) too long a time.

Thanks,
Nick
