From: Andi Kleen <ak@suse.de>
Date: Mon, 23 Jan 2006 08:52:53 +0000
Subject: Re: ia64: allnoconfig build fails
Message-Id: <200601230952.54247.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601210320.05771.len.brown@intel.com>
In-Reply-To: <200601210320.05771.len.brown@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Saturday 21 January 2006 20:14, Chen, Kenneth W wrote:
> Len Brown wrote on Saturday, January 21, 2006 12:20 AM
> > mm/mempolicy.c: In function `huge_zonelist':
> > mm/mempolicy.c:1045: error: `HPAGE_SHIFT' undeclared (first use in
> this function)
> > mm/mempolicy.c:1045: error: (Each undeclared identifier is reported
> only once
> > mm/mempolicy.c:1045: error: for each function it appears in.)
> > make[1]: *** [mm/mempolicy.o] Error 1
> 
> Need to wrap huge_zonelist function with CONFIG_HUGETLBFS.

I queued it thanks. Unfortunately the patch was word wrapped and MIME damaged. 
I fixed this, but please be more careful with that next time.

Thanks,
-Andi
