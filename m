From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 04 Feb 2004 03:28:56 +0000
Subject: Re: PCI question
Message-Id: <20040204032856.GC11566@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200402032235.i13MZQXl018906@fsgi900.americas.sgi.com>
In-Reply-To: <200402032235.i13MZQXl018906@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 03, 2004 at 05:36:53PM -0600, Patrick Gefre wrote:
> But not in 2.6 ??
> 
> struct pci_controller {
>        void *acpi_handle;
>        void *iommu;
>        int segment;
> 
>        unsigned int windows;
>        struct pci_window *window;
> };

Oops, I was looking at a 2.4 tree.  I wonder if we can overload
acpi_handle for our purposes though?  Since we don't have an ACPI
namespace, we obviously don't store things like the bridge base address
and PIO mapping information there, so we may be able to make this field
point to an sn2 specific structure that contains this info (I'm assuming
that's what we need).

What else do we need to keep track of?  The PCI to node mapping should
be stored seperately (I think mkp had a patch to implement that), but
I'm sure there are other things I'm missing...

Thanks,
Jesse
