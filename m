From: Andi Kleen <ak@suse.de>
Date: Thu, 05 Aug 2004 13:43:46 +0000
Subject: Re: Hugetlb demanding paging for -mm tree
Message-Id: <20040805134346.GD16763@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408051329.i75DT3Y26431@unix-os.sc.intel.com>
In-Reply-To: <200408051329.i75DT3Y26431@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Seth, Rohit" <rohit.seth@intel.com>

> Patches are broken into two pieces.  But they should be applied together
> to have correct functionality for hugetlb demand paging.
> 
> 00.demandpaging.patch - core hugetlb demand paging
> 01.overcommit.patch   - hugetlbfs strict overcommit accounting.
> 
> Testing and comments are welcome.  Thanks.

Looks good so far to me. I can later add NUMA API on top of it.
Just one nit: please add a printk for the OOM case.
And: please don't send patches uuencoded, that makes it harder 
to review.

I didn't see the second part yet.

-Andi
