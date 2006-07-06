From: Horms <horms@verge.net.au>
Date: Thu, 06 Jul 2006 08:24:20 +0000
Subject: Re: [PATCH] ia64, kexec: allow base of crashkernel to be auto-discovered
Message-Id: <20060706082418.GA602@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060628110052.GA11751@verge.net.au>
In-Reply-To: <20060628110052.GA11751@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jul 05, 2006 at 12:16:41PM -0700, Luck, Tony wrote:
> > I might be confused, but I'm not exactly sure that my patch would run
> > into this problem. It only tries to insert the "Crash kernel" resource
> > as a sub-resource of an existing "System RAM" resource, and does so in
> > such a way that it should not overlap with any existing sub-resources.
> > Surely VGA and the like are in completely different resources not
> > covered by a "System RAM" resource.
> 
> The problem is that _nearby_ resources may require different attributes,
> yet be mapped by a single TR entry.  E.g. on an Intel Tiger there is a
> "System RAM" resource from 0x100000-0x3ffffff, but if you place the kernel
> image into it, then ITR[0] and DTR[0] will map the entire 64M from
> 0x0 to 0x3ffffff, which includes the VGA.

Thanks. I did a bit of research based of this, am I correct in thinking
that this relates to the way that ITR[0] and DTR[0] are setup in _start?

        mov r3=ip
        movl r18=PAGE_KERNEL
        ;;
        dep r2=0,r3,0,KERNEL_TR_PAGE_SHIFT
        ;;
        or r18=r2,r18
        ;;
        srlz.i
        ;;
        itr.i itr[r16]=r18
        ;;
        itr.d dtr[r16]=r18

Or in other words, the base address is calculated by taking the ip
and masking it such that it is rounded down to 64Mb (1 << KERNEL_TR_PAGE_SHIFT).

With this in mind, I guess that ensuring that the reservation is
aligned to 64Mb (as the patch I sent yesterday does) should not
exhibit the problem that you describe.

Users can still ask for crashkernel to have a a non-64Mb aligned base,
and in the example you give above it will likely succeed. I wonder if
this is something that the crashkernel command parser should complain
about, or even discard/modify non-64Mb aligned values. On the other
hand, hopefully my idea of letting the kernel work out the appropriate
base will become the norm, and in that case if someone asks for some
other address, they should probably get exactly what they ask for. In
which case it really just becomes an issue of documenting it somewhere,
somehow, someday...

On a related note, I suspect that if the region is < 64Mb in size (or
not a multiple of 64Mb in size?) there will be some trouble relating to
mappings, after all, the ITIR is set up for 64Mb pages. But hand, I
strongly doubt the kernel can boot in less that that much memory, and so
perhaps it isn't a problem that needs to be worried about.

-- 
Horms                                           
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

