From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 09 Feb 2005 18:19:43 +0000
Subject: Re: [PATCH] CPU hotplug returns CPUs to SAL
Message-Id: <1107973183.5478.31.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <1107970828.5478.22.camel@tdi>
In-Reply-To: <1107970828.5478.22.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Ashok,

   Sorry I missed your patch.  Your assembly is certainly cleaner than
mine.  We seem to have several differences in the state that actually
gets saved and restored though.  For instance, I see you're saving k0,
which is listed as scratch in the spec, but none of the fp, predicate,
branch registers, region registers, or preserved general registers.
Shouldn't a few more of those be preserved under "standard calling
conventions"?  Also, what do you think about treating the saved state as
a stack?  This could eventually allow the BSP to be sent off spinning in
SAL.  Thanks,

	Alex

On Wed, 2005-02-09 at 09:53 -0800, Ashok Raj wrote:
> On Wed, Feb 09, 2005 at 09:40:28AM -0800, Alex Williamson wrote:
> 
> Hi Alex
> 
> In fact i did submit a patch for this about a month ago. I was sharing some
> code from mca side for tlb purge, and this code has been in the swamp for 
> several weeks now. I hope they are settled now, and  i will re submit my 
> patches once again.
> 
> link from old post
> 
> http://marc.theaimsgroup.com/?l=linux-ia64&m0239954713260&w=2
> 
> I will repost to match whats there in tony-'s test/release tree asap.
> 
> ashok
> > 
> >        When  a  CPU  is sent offline, it currently goes into a dummy spin
> >    loop
> >    and  pretends  to be gone.  This patch returns the CPU back to SAL via
> >    the
> >    mechanism described in the SAL spec.  The state of secondary CPUs is
> >    saved off to a dynamically allocated stack for use on return to SAL.
> >    I've munged the _start code in head.S to avoid trampling over some of
> >    the preserved registers before we get a chance to save them.  The
> >    assembly could probably use some optimizations, but these are hardly
> >    performance paths.  It seems to work reliably on zx1 and sx1000 boxes,
> >    but needs some exposure on others.  Patch against current bk.  Thanks,
> > 
> >            Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

