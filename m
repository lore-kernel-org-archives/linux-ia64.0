From: Hirokazu Takahashi <taka@valinux.co.jp>
Date: Sat, 13 Mar 2004 04:56:38 +0000
Subject: Re: Hugetlbpages in very large memory machines.......
Message-Id: <20040313.135638.78732994.taka@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <40528383.10305@sgi.com>
In-Reply-To: <40528383.10305@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: raybry@sgi.com
Cc: lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, n-yoshida@pst.fujitsu.com

Hello,

My following patch might help you. It inclueds pagefault routine
for hugetlbpages. If you want to use it for your purpose, you need to
remove some code from hugetlb_prefault() that will call hugetlb_fault().
http://people.valinux.co.jp/~taka/patches/va01-hugepagefault.patch

But it's just for IA32.

I heard that n-yoshida@pst.fujitsu.com was porting this patch
on IA64.

> We've run into a scaling problem using hugetlbpages in very large memory machines, e. g. machines 
> with 1TB or more of main memory.  The problem is that hugetlbpage pages are not faulted in, rather 
> they are zeroed and mapped in in by hugetlb_prefault() (at least on ia64), which is called in 
> response to the user's mmap() request.  The net is that all of the hugetlb pages end up being 
> allocated and zeroed by a single thread, and if most of the machine's memory is allocated to hugetlb 
> pages, and there is 1 TB or more of main memory, zeroing and allocating all of those pages can take 
> a long time (500 s or more).
> 
> We've looked at allocating and zeroing hugetlbpages at fault time, which would at least allow 
> multiple processors to be thrown at the problem.  Question is, has anyone else been working on
> this problem and might they have prototype code they could share with us?
> 
> Thanks,
> -- 
> Best Regards,
> Ray


Thank you,
Hirokazu Takahashi.
