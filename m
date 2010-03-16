From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Tue, 16 Mar 2010 23:16:23 +0000
Subject: Re: [PATCH v4 05/11] swiotlb: add swiotlb_set_default_size()
Message-Id: <20100317081003G.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <4B9F1E11.80201@yahoo.es>
	<20100316190805Z.fujita.tomonori@lab.ntt.co.jp>
	<C200C089-E6B9-4836-A7B5-3233EB2CE5FB@kernel.crashing.org>
In-Reply-To: <C200C089-E6B9-4836-A7B5-3233EB2CE5FB@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: beckyb@kernel.crashing.org
Cc: fujita.tomonori@lab.ntt.co.jp, albert_herranz@yahoo.es, benh@kernel.crashing.org, linux-usb@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org

On Tue, 16 Mar 2010 14:28:09 -0500
Becky Bruce <beckyb@kernel.crashing.org> wrote:

> 
> On Mar 16, 2010, at 5:08 AM, FUJITA Tomonori wrote:
> 
> > On Tue, 16 Mar 2010 06:58:41 +0100
> > Albert Herranz <albert_herranz@yahoo.es> wrote:
> >
> >> FUJITA Tomonori wrote:
> >>> On Fri, 12 Mar 2010 20:12:40 +0100
> >>> Albert Herranz <albert_herranz@yahoo.es> wrote:
> >>>
> >>>> The current SWIOTLB code uses a default of 64MB for the IO TLB  
> >>>> area.
> >>>> This size can be influenced using a kernel command line parameter  
> >>>> "swiotlb".
> >>>> Unfortunately, the parsing of the kernel command line is done  
> >>>> _after_ the
> >>>> swiotlb is initialized on some architectures.
> >>>>
> >>>> This patch adds a new function swiotlb_set_default_size() which  
> >>>> can be used
> >>>> before swiotlb_init() to indicate the desired IO TLB area size in  
> >>>> bytes.
> >>>>
> >>>> This will be used later to implement a smaller IO TLB on the  
> >>>> Nintendo Wii
> >>>> video game console which just comes with 24MB + 64MB of RAM.
> >>>>
> >>>> CC: linuxppc-dev@lists.ozlabs.org
> >>>> CC: linux-kernel@vger.kernel.org
> >>>> CC: x86@kernel.org
> >>>> CC: linux-ia64@vger.kernel.org
> >>>> Signed-off-by: Albert Herranz <albert_herranz@yahoo.es>
> >>>> ---
> >>>> include/linux/swiotlb.h |    2 ++
> >>>> lib/swiotlb.c           |   20 ++++++++++++++++++++
> >>>> 2 files changed, 22 insertions(+), 0 deletions(-)
> >>>
> >>> Please fix the powerpc swiotlb initialization instead.
> >>>
> >>> Calling swiotlb_init() before parsing kernel parameters sounds
> >>> wrong. Any reasons why you can't fix it?
> >>>
> >>
> >> I think that this would be better asked by a PowerPC maintainer. Ben?
> >>
> >> If this is really a problem the swiotlb late init may be a solution  
> >> too in this particular case.
> >
> > Hmm, why swiotlb_late_init_with_default_size()?
> >
> > Why can't you initialize swiotlb in mem_init() like this (only compile
> > tested)? Any time before freeing bootmem works for swiotlb.
> 
> This is an oops in the original patchset -  I think it should be fine  
> to move the swiotlb_init later as Fujita suggests, at least for 32-bit  
> powerpc.  I just booted this on mpc8641 and everything seems OK.

Thanks!

I'll resend this patch in the proper format. This patch fixes the
problem that powerpc ignores swiotlb boot options so we can merge it
independent of Albert's patchset.
