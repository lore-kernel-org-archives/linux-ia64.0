From: Ray Bryant <raybry@sgi.com>
Date: Sat, 13 Mar 2004 03:45:09 +0000
Subject: Hugetlbpages in very large memory machines.......
Message-Id: <405283C5.5060702@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40528383.10305@sgi.com>
In-Reply-To: <40528383.10305@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lse-tech@lists.sourceforge.net, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-kernel@vger.kernel.org

We've run into a scaling problem using hugetlbpages in very large memory machines, e. g. machines 
with 1TB or more of main memory.  The problem is that hugetlbpage pages are not faulted in, rather 
they are zeroed and mapped in in by hugetlb_prefault() (at least on ia64), which is called in 
response to the user's mmap() request.  The net is that all of the hugetlb pages end up being 
allocated and zeroed by a single thread, and if most of the machine's memory is allocated to hugetlb 
pages, and there is 1 TB or more of main memory, zeroing and allocating all of those pages can take 
a long time (500 s or more).

We've looked at allocating and zeroing hugetlbpages at fault time, which would at least allow 
multiple processors to be thrown at the problem.  Question is, has anyone else been working on
this problem and might they have prototype code they could share with us?

Thanks,
-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------

