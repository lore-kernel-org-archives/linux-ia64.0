From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 06 Jan 2006 17:49:57 +0000
Subject: Re: [PATCH] ia64: change defconfig to NR_CPUS==1024
Message-Id: <20060106174957.GF19769@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F055A7B6B@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F055A7B6B@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Arjan van de Ven <arjan@infradead.org>, hawkes@sgi.com, Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Dan Higgins <djh@sgi.com>, John Hesterberg <jh@sgi.com>, Greg Edwards <edwardsg@sgi.com>

On Fri, Jan 06, 2006 at 09:45:20AM -0800, Luck, Tony wrote:
> I suppose that depends on your expectations from defconfig.  In my
> mind its the one that builds into a kernel that will boot and run
> on just about any box.  People who want to get a bit of extra performance
> will do the re-compilation to strip out the bits that they don't want
> and tune down limits that are set higher than they need.  I only

You can use that argument to set the CPU limit low too -- since a kernel
with a CPU limit lower than the number of CPUs in the box will just ignore
the additional ones, people who want to get the additional performance
will tune limits that are set lower than they need ;-)

> ever boot a defconfig kernel to check that it still works, my systems
> all run tiger_defconfig/zx1_defconfig based most of the time.  But
> perhaps I'm the weird one?
> 
> There are quite a few >16 socket boxes out there, which will give
> you >64 cpus with Montecito ... so I don't think that the >64 cpu
> system is going to remain in the noise for long.

I bet the number of 32-way+ boxes is lost in the noise compared to the
number of 1-, 2- and 4-way boxes sold.  Not that HP trust me with that
kind of sales data ;-)
