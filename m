From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 28 Jul 2008 12:48:56 +0000
Subject: Re: [patch] crashdump: fix undefined reference to `elfcorehdr_addr'
Message-Id: <20080728124856.GF5515@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080727234529.GM6175@verge.net.au> <20080728015117.GA12055@verge.net.au> <20080728024526.GB3334@verge.net.au> <20080728034007.GA30450@verge.net.au>
In-Reply-To: <20080728034007.GA30450@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Muli Ben-Yehuda <muli@il.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Chandru <chandru@in.ibm.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, Terry Loftin <terry.loftin@hp.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Linus Torvalds <torvalds@linux-foundation.org>, Vivek Goyal <vgoyal@redhat.com>


* Simon Horman <horms@verge.net.au> wrote:

> On Mon, Jul 28, 2008 at 12:45:28PM +1000, Simon Horman wrote:
> > The rfc patch I made to rename is_kdump_kernel to kernel_has_vmcore,
> > which I appended to my previous post should have looked more like the
> > following. Although, as I noted in my previous post, its more a starting
> > point for discussion than a solution to the problem at hand.
> 
> Sorry, one more time. I forgot to quilt refresh.

doesnt apply cleanly to latest -git:

 Hunk #1 FAILED at 2070.
 1 out of 1 hunk FAILED -- saving rejects to file arch/ia64/hp/common/sba_iommu.c.rej

due to a crossing change i guess. Also, i guess this should go via -mm 
as it touches fs/proc/vmcore.c and include/linux/crash_dump.h. The x86 
bits look good to me.

 Acked-by: Ingo Molnar <mingo@elte.hu>

	Ingo
