From: Shehjar Tikoo <shehjart@cse.unsw.edu.au>
Date: Thu, 06 Nov 2008 03:01:19 +0000
Subject: Re: Panic in multiple kernels: IA64 SBA IOMMU: Culprit commit on
Message-Id: <49125DFF.5080900@cse.unsw.edu.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <490F880E.4000801@cse.unsw.edu.au> <57C9024A16AD2D4C97DC78E552063EA35BE05F00@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA35BE05F00@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "fujita.tomonori@lab.ntt.co.jp" <fujita.tomonori@lab.ntt.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-parisc@vger.kernel.org

Luck, Tony wrote:
> Added Cc: linux-ia64 ... more likely to attract attention of HP
> ia64 experts there.
> 
>> arch/ia64/hp/common/sba_iommu.c: I/O MMU is out of mapping resources
> 
> Odd ... the code (back to the dawn of git time in 2.6.12-rc1) looks like
> 
>         panic(__FILE__ ": I/O MMU @ %p is out of mapping resources\n"
>                 ioc->ioc_hpa);
> 
> I wonder why you don't see the "@ HEXADDRESS"?

That was copy paste from memory. You're right. There is a hex address.
I've copied a full message at the end of the email.

> 
>> Using git-bisect, I've zeroed in on the commit that introduced this.
>> Please see the attached file for the commit.
> 
> Did you confirm that reverting this commit on a recent kernel
> fixes the problem (once in a while git bisect can point to
> the wrong commit ... it seems very likely that it got the
> right one here, but it is always good to check).  When I
> tried to use "patch -R" to revert this it got confused on
> the Kconfig file because the lines that were added were
> subsequently changed ... so you may need to revert that
> by hand ... the sba_iommu.c apparently reverted ok).


Yes, reverting this commit in 2.6.27 prevents kernel panic on both
workloads.

> 
>> Other info:
>> System is HP RX6600(16Gb RAM, 16 processors w/ dual cores and HT)
>> 20 SATA disks under software RAID0 with 6 TB capacity.
>> Silicon Image 3124 controller.
>> File system is XFS.
> 
> My HP test system is way too small to attempt to recreate
> this (just 2 cpus & 1 disk).  How long does each of your
> tests take to hit the problems ... a few minutes? Or hours?

The points at which panic occur are variable for both tests but
generally, I felt the panics were occurring nearer to the end of the
750G to 1TB writes.

> 
>> I'd much appreciate some help in fixing this because this panic has
>> basically stalled my own work. I'd be willing to run more tests on my
>> setup to test any patches that possibly fix this issue.
> 
> Adding some printk() before the panic might give a clue as to what
> is going wrong.  Either a bogus call is trying to allocate far
> too much space, or the bitmap is leaking, or we have a totally
> messed up "ioc" structure.
> 
> Printing "pages_needed" the address of "ioc" and some interesting
> fields from ioc (at least ioc->res_size) would help.  I assume
> the the return value from sba_search_bitmap() is ~0x0 ... but
> you should print "pide" just to be sure.


Heres some more info from a printk:

Kernel panic - not syncing: arch/ia64/hp/common/sba_iommu.c: I/O MMU @ 
c0000000fed01000 is out of mapping resources: pide: 
18446744073709551615, pages_needed: 5, iocres_size: 8192

> 
> -Tony

