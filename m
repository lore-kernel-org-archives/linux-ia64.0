From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 27 Jul 2004 14:49:06 +0000
Subject: Re: [BROKEN PATCH] kexec for ia64
Message-Id: <200407270749.07034.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com>
In-Reply-To: <200407261524.40804.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, July 27, 2004 1:24 am, Christian Hildner wrote:
> Jesse Barnes schrieb:
> >I'm also worried about a few things in this patch.  Is relocate_kernel.S
> >really necessary in 2.6?  Can we copy the kernel to a contiguous 64MB
> > aligned area, drop into phys mode and just jump to it?
>
> You should be safe with that but you should consider flushing TLB
> entries of the old kernel before the newly started kernel inserts its
> own translations.

Right, probably a good idea.

Jesse
