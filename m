From: "Bob Picco" <bob.picco@hp.com>
Date: Wed, 03 May 2006 18:30:56 +0000
Subject: Re: strcpy returns NULL pointer and not destination pointer
Message-Id: <20060503183056.GF19859@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060503133806.GC19859@localhost>
In-Reply-To: <20060503133806.GC19859@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:	[Wed May 03 2006, 02:08:47PM EDT]
> Bob Picco wrote on Wednesday, May 03, 2006 6:38 AM
> > The removal of -ffreestanding compiler flag in 2.6.17-rcX (commit id
> > 6edfba1b33c701108717f4e036320fc39abe1912) causes strcpy calls 
> > with a known size for the source string to be replaced with memcpy which
> > is faster.  ia64 memcpy has return values which are unlike stdlibc and
> > the other arch memcpy routines examined by me in the kernel.  The ia64 return
> > values are 0 for success and number of bytes copied for failure. Thus any
> > instance of pointer = strcpy(dest, "some string") has zero assigned to
> > pointer.  I detected this when testing kgdb on 2.6.17-rc3.  
> > 
> > The implementation in memcpy_mck.S doesn't leave a single scratch
> > register or predicate. I didn't pursue very long for a solution.
> 
> I thought I fixed that about 3 years ago:
> 
> http://marc.theaimsgroup.com/?l=linux-ia64&m5590709805435&w=2
> 
> Did it fall through the crack?  I'm not sure what's going on.
> 
> - Ken
It looks to have definitely fallen through a crack or two.

I applied to rc3 and boot tested for you. I assume you'll post patch again.

bob
