From: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Date: Thu, 06 May 2004 18:47:38 +0000
Subject: RE: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <D36CE1FCEFD3524B81CA12C6FE5BCAB002FFEB1B@fmsmsx406.fm.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <003801c43347$812a1590$39624c0f@india.hp.com>
In-Reply-To: <003801c43347$812a1590$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>, Sourav Sen <souravs@india.hp.com>
Cc: "HELGAAS,BJORN (HP-Ft. Collins)" <bjorn_helgaas@am.exch.hp.com>, Matt Domsch <Matt_Domsch@dell.com>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Luck, Tony" <tony.luck@intel.com>

> On Thu, 2004-05-06 at 09:25, Sourav Sen wrote:
> > From: Bjorn Helgaas [mailto:bjorn.helgaas@hp.com]
> > + For this application, the EFI memory map isn't what you want.
> > + It's a pretty good approximation today, but the day when we'll
> > + be able to hot-add memory is fast approaching, and the EFI map
> > + won't mention anything added after boot.  We'll discover all
> > + that via ACPI (on ia64).
> >
> > 	Why not also update the efi memory table on a hotplug :-)
> 
> That's actually what ppc64 does.  But, they do it via /proc (not even
> from inside the kernel).  I'm not very fond of that solution :)

Interesting. What does ppc64 do with the memmap after that?  

> >  and there may be some truncation (just as efi_memmap_walk()
> > does today). And it isn't help us if we get to know about those
> > extents. Additionally we get to know about various mmio ranges and
> > other ranges thru that table -- may be useful opportunistically.
> 
> There can be some pretty generic (although asynchronous) events given
> via /sbin/hotplug.  I'm currently planning on having the 
> memory hotplug
> "drivers" get the hot-added memory ready, but keep it 
> offline.  It then
> creates some kobjects, which generate hotplug events, and *then* the
> decision can be made in the hotplug scripts about what to do with it.

So, allocate the page structs which constitute the new memmap, set up
the nonlinear sections, and then wait for hotplug events in order to 
clear the appropriate bits in the pages for a given range?  Is that 
what you're thinking?

matt
