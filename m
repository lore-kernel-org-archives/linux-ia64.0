From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 04 May 2004 17:27:21 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <200405041027.21466.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, May 4, 2004 10:14 am, Grant Grundler wrote:
> On Tue, May 04, 2004 at 09:54:09AM -0700, Jesse Barnes wrote:
> > Another issue is that the
> > MCA event may arrive after the processor has switched to a task
> > completely unrelated to the I/O.  The approach I've taken thus far is to
> > register the I/O address range that a process mmaps in /proc/bus/pci (in
> > pci_mmap_page_range), along with its associated PID.
>
> Why not use the existing resource map?
> The PCI bus data structures are hierarchial and resources are well
> defined in that. Seems like the linked list of I/O ranges could (1)
> get very long and (2) just replicates what's already there.

You mean just use request_region at pci_mmap_page_range time instead?  That 
would prevent multiple processes from accessing the same region, but we'd 
still want to know the PID of the process that had that range reserved (the 
gfx guys really want to get a signal when an I/O error occurs so they can 
recover in userspace; other userspace drivers probably want the same).  
Another problem is that legacy I/O space isn't listed in any of the PCI 
resource maps (at least as far as I know), so there would be no way to track 
that region, which is the one that I'm *really* interested in. :)

> > Ultimately, this involves adding a machine vector for I/O error recovery
> > and a linked list of I/O regions and their PIDs.  The I/O error handler
> > could optionally be extended to look for any PCI resource range and call
> > a per-device error handling callback or shutdown routine.
> >
> > Thoughts?  Does this approach sound reasonable?
>
> Seems to fit nicely with previous pci_read_check() support proposed
> earlier.

Yeah, it could be tied in with that interface.

Jesse
