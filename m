From: Grant Grundler <iod00d@hp.com>
Date: Tue, 04 May 2004 17:14:51 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <20040504171451.GE1701@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 04, 2004 at 09:54:09AM -0700, Jesse Barnes wrote:
> Another issue is that the 
> MCA event may arrive after the processor has switched to a task completely 
> unrelated to the I/O.  The approach I've taken thus far is to register the 
> I/O address range that a process mmaps in /proc/bus/pci (in 
> pci_mmap_page_range), along with its associated PID.

Why not use the existing resource map?
The PCI bus data structures are hierarchial and resources are well
defined in that. Seems like the linked list of I/O ranges could (1)
get very long and (2) just replicates what's already there.

> Ultimately, this involves adding a machine vector for I/O error recovery and a 
> linked list of I/O regions and their PIDs.  The I/O error handler could 
> optionally be extended to look for any PCI resource range and call a 
> per-device error handling callback or shutdown routine.
> 
> Thoughts?  Does this approach sound reasonable?

Seems to fit nicely with previous pci_read_check() support proposed
earlier.

grant
