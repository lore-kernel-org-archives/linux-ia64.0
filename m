From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 04 Nov 2008 22:13:39 +0000
Subject: RE: Panic in multiple kernels: IA64 SBA IOMMU: Culprit commit on
Message-Id: <57C9024A16AD2D4C97DC78E552063EA35BE05F00@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <490F880E.4000801@cse.unsw.edu.au>
In-Reply-To: <490F880E.4000801@cse.unsw.edu.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Shehjar Tikoo <shehjart@cse.unsw.edu.au>, "fujita.tomonori@lab.ntt.co.jp" <fujita.tomonori@lab.ntt.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

Added Cc: linux-ia64 ... more likely to attract attention of HP
ia64 experts there.

> arch/ia64/hp/common/sba_iommu.c: I/O MMU is out of mapping resources

Odd ... the code (back to the dawn of git time in 2.6.12-rc1) looks like

        panic(__FILE__ ": I/O MMU @ %p is out of mapping resources\n"
                ioc->ioc_hpa);

I wonder why you don't see the "@ HEXADDRESS"?

> Using git-bisect, I've zeroed in on the commit that introduced this.
> Please see the attached file for the commit.

Did you confirm that reverting this commit on a recent kernel
fixes the problem (once in a while git bisect can point to
the wrong commit ... it seems very likely that it got the
right one here, but it is always good to check).  When I
tried to use "patch -R" to revert this it got confused on
the Kconfig file because the lines that were added were
subsequently changed ... so you may need to revert that
by hand ... the sba_iommu.c apparently reverted ok).

> Other info:
> System is HP RX6600(16Gb RAM, 16 processors w/ dual cores and HT)
> 20 SATA disks under software RAID0 with 6 TB capacity.
> Silicon Image 3124 controller.
> File system is XFS.

My HP test system is way too small to attempt to recreate
this (just 2 cpus & 1 disk).  How long does each of your
tests take to hit the problems ... a few minutes? Or hours?

> I'd much appreciate some help in fixing this because this panic has
> basically stalled my own work. I'd be willing to run more tests on my
> setup to test any patches that possibly fix this issue.

Adding some printk() before the panic might give a clue as to what
is going wrong.  Either a bogus call is trying to allocate far
too much space, or the bitmap is leaking, or we have a totally
messed up "ioc" structure.

Printing "pages_needed" the address of "ioc" and some interesting
fields from ioc (at least ioc->res_size) would help.  I assume
the the return value from sba_search_bitmap() is ~0x0 ... but
you should print "pide" just to be sure.

-Tony
