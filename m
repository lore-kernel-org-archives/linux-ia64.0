From: William Lee Irwin III <wli@holomorphy.com>
Date: Wed, 14 Jul 2004 09:17:15 +0000
Subject: Re: free bootmem feedback patch
Message-Id: <20040714091715.GM3411@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 13, 2004 at 05:59:46PM -0500, Joshua Aas wrote:
> NUMA machines with a lot of memory/nodes appear to hang when freeing boot 
> memory, as it can take on the order of 4 minutes. I would like to propose 
> this patch, which adds progress feedback during this time. On a machine 
> with only one memory region (a single node), it prints:
> Freeing boot memory... done
> It prints more dots every x nodes handled based on the total number of 
> nodes, in such a way that the line never exceeds 80 chars. This way it is 
> possible to see progress being made. I have tested this on a few machines, 
> including a 512p/512GB machine, and it works fine.

Could I get a look at the memory map for this machine?

Also, it may make more sense to speed this up by freeing higher-order
pages at a time.


-- wli
