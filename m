From: Thomas Gleixner <tglx@linutronix.de>
Date: Tue, 11 Nov 2014 21:36:39 +0000
Subject: Re: [PATCH v9 11/12] x86, mpx: cleanup unused bound tables
Message-Id: <alpine.DEB.2.11.1411112233180.3935@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-12-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241451280.5308@nanos> <545BED0B.8000001@intel.com> <alpine.DEB.2.11.1411111213450.3935@nanos>
 <54627512.7060806@intel.com>
In-Reply-To: <54627512.7060806@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <dave.hansen@intel.com>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On Tue, 11 Nov 2014, Dave Hansen wrote:
> On 11/11/2014 10:27 AM, Thomas Gleixner wrote:
> > On Thu, 6 Nov 2014, Dave Hansen wrote:
> >> Instead of all of these games with dropping and reacquiring mmap_sem and
> >> adding other locks, or deferring the work, why don't we just do a
> >> get_user_pages()?  Something along the lines of:
> >>
> >> while (1) {
> >> 	ret = cmpxchg(addr)
> >> 	if (!ret)
> >> 		break;
> >> 	if (ret = -EFAULT)
> >> 		get_user_pages(addr);
> >> }
> >>
> >> Does anybody see a problem with that?
> > 
> > You want to do that under mmap_sem write held, right? Not a problem per
> > se, except that you block normal faults for a possibly long time when
> > the page(s) need to be swapped in.
> 
> Yeah, it might hold mmap_sem for write while doing this in the unmap
> path.  But, that's only if the bounds directory entry has been swapped
> out.  There's only 1 pointer of bounds directory entries there for every
> 1MB of data, so it _should_ be relatively rare.  It would mean that
> nobody's been accessing a 512MB swath of data controlled by the same
> page of the bounds directory.
> 
> If it gets to be an issue, we can always add some code to fault it in
> before mmap_sem is acquired.

I don't think it's a real issue.
 
> FWIW, I believe we have a fairly long road ahead of us to optimize MPX
> in practice.  I have a list of things I want to go investigate, but I
> have not looked in to it in detail at all.

:)
 
> > But yes, this might solve most of the issues at hand. Did not think
> > about GUP at all :(
> 
> Whew.  Fixing it was getting nasty and complicated. :)

Indeed. Though I think that distangling specific parts of MPX from
mmap_sem is still a worthwhile exercise. So not all of the complex
ideas we came up with during the discussion are lost in the pointless
complexity universe :)

Thanks,

	tglx
