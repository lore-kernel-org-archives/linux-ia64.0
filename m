From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 09 Feb 2005 19:44:18 +0000
Subject: Re: [PATCH] CPU hotplug returns CPUs to SAL
Message-Id: <1107978258.5478.55.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <1107970828.5478.22.camel@tdi>
In-Reply-To: <1107970828.5478.22.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2005-02-09 at 11:26 -0800, Ashok Raj wrote:
> 
> Section 3.2.4 seemed to indicate that SAL versions executing IA32 BIOS code
> would have the IA32 I/O PORT block. That prompted me to save that even though 
> it was listed as scratch in the following section. (Maybe just required for
> BSP?)

   Yeah, I think we've already got all the information for I/O port
base, so it should only be an issue of SAL needing that.  According to
the spec, it shouldn't.

> True. When i was testing, i ran into an issue with restoring region registers
> Dont remember quite what it was, that prompted me to not do it for
> that round of testing. It didnt seem to affect anything and appeared to
> work fine on the tiger4 systems. 

   FWIW, I had to add the srlz.d to prevent a RAW #RR warning.  Perhaps
that was the issue.

> > Also, what do you think about treating the saved state as
> > a stack?  This could eventually allow the BSP to be sent off spinning in
> > SAL.  Thanks,
> 
> Technically the same method should work for BSP as well, but since BSP ran 
> the bootloader, unless he saves it and exposes it in a standard way to OS
> we cannot restore. (Agreed very UGLY)

   But the BSP doesn't need to save anything.  We'll always have N-1 SAL
states saved and N-1 CPUs that can be taken offline.  As long as we
don't hard link a state to a specific CPU, we're in good shape.  I've
been testing on my boxes with an order that intentionally gives CPUs the
state saved off of another CPU on OS entry.  I appear to be able to make
the BSP return to SAL as well, but I don't think the rest of the hotplug
code is ready for this (the other CPU doesn't seem to be getting
scheduled).  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

