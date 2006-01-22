From: Andi Kleen <ak@suse.de>
Date: Sun, 22 Jan 2006 01:42:45 +0000
Subject: Re: ia64: allnoconfig build fails
Message-Id: <200601220242.46298.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601210320.05771.len.brown@intel.com>
In-Reply-To: <200601210320.05771.len.brown@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Saturday 21 January 2006 22:11, Luck, Tony wrote:
> > Need to wrap huge_zonelist function with CONFIG_HUGETLBFS.
> >
> >
> > Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
> 
> Fixes this new problem ... allnoconfig still fails for me
> with lots of:
> 
>      undefined reference to `vmem_map'
> 
> and a few
> 
>      undefined reference to `ia64_pfn_valid'
> 
> but these have been around for a while.

Trying without CONFIG_NUMA but with virtual memory map also doesn't work.
Also some of the other obvious combinations in the mm space are broken.
Found this last time I updated the kernel on my ia64 box.

-Andi
