From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 20 Jun 2008 02:03:56 +0000
Subject: Re: [PATCH 09/27] ia64/xen: implement the arch specific part of xencomm.
Message-Id: <20080620020356.GA16478%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12130840434082-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12130840434082-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 19, 2008 at 10:15:09AM -0700, Luck, Tony wrote:
> >> +#define is_kernel_addr(x)                                      \
> >> +       ((PAGE_OFFSET <= (x) &&                                 \
> >> +         (x) < (PAGE_OFFSET + (1UL << IA64_MAX_PHYS_BITS))) || \
> >> +        (KERNEL_START <= (x) &&                                \
> >> +         (x) < KERNEL_START + KERNEL_TR_PAGE_SIZE))
> >>
> >> Misleading name.  What does it consider a "kernel_addr"? Just
> >> region 7 (up to physical address limit) and the piece of region
> >> 5 that is mapped by itr[0]/dtr[0].  Preferebly pick a better name
> >> or add a comment here saying what this is testing for.
> >
> > How about xencomm_is_phys_contiguous()?
> > Renaming it requires patches to drivers/xen/xencomm.c.
> > If okay, I'll also send the patch to common files.
> 
> That sounds a bit more meaningful ... except that such a function
> would also require a "size" (or "end") parameter. It makes
> no sense to ask whether a solitary address is contiguous.

Strictly that's right. But for a contiguous region in virutal address
which is used for a variable, it is sufficient to check only its
pointer addresses.

-- 
yamahata
