From: Horms <horms@verge.net.au>
Date: Mon, 26 Jun 2006 08:37:08 +0000
Subject: Re: [Fastboot] Ia64 kdump patch
Message-Id: <20060626083707.GD20679@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060608083516.GH28607@verge.net.au>
In-Reply-To: <20060608083516.GH28607@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jun 26, 2006 at 04:10:44PM +0800, Zou, Nanhai wrote:
>   The list is a bit wrong.., I notice that we don't need to dump
>   unwind segment to core file for stack unwind to work... I am working
>   on full register dumping and fixing the stack unwind issue.

Awsome, if you have anything that needs testing I am more than
happy to help. I am a bit confused about which registers are
saved and which aren't in the current code, but I figure that mainly
relates to the code being incomplete.

>  The PCI device shutdown code was to un-master all the PCI devices so that no DMA transaction will be issued by Device. However I think maybe we can remove this code because the new kernel memory space is invisible to first kernel.

Ok, that makes a lot of sense. I was really puzzling over
why ia64 does this but x86_32 doesn't. I also suspect it
can be safely removed. Would you like me to test that out
and send a patch if it works?

> There is another problem that I call irq->end for each devices, it is
> not safe to touch any pointer belong to previous kernel at the crash
> time.  But without this code, MPT fusion driver is very likely unable
> to restart. It sometimes failed to restart even with the irq->end
> code. This is an open issue need to be fixed.

Right, that does sound quite nicely, especially as that device is quite
common, right?

-- 
Horms                                           
H: http://www.vergenet.net/~horms/          W: http://www.valinux.co.jp/en/

