From: Rajesh Shah <rajesh.shah@intel.com>
Date: Thu, 20 Jan 2005 02:14:32 +0000
Subject: Re: [PATCH] Convert acpiphp to use generic resource code
Message-Id: <20050119181432.B12618@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050119185120.GE25940@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20050119185120.GE25940@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 19, 2005 at 01:44:58PM -0800, Greg KH wrote:
> On Wed, Jan 19, 2005 at 06:51:20PM +0000, Matthew Wilcox wrote:
> > 
> > This patch converts acpiphp to use the generic PCI resource assignment
> > code.  It's quite large, but most of it is deleting the acpiphp_pci and
> > acpiphp_res files.  It's tested on an hp Integrity rx8620 (which won't
> > work without this patch).  Testers with other hardware welcomed.
> 
> Unfortunatly I don't have access to any systems that support acpi pci
> hotplug.  Anyone else out there able to test this patch to make sure it
> works properly on their i386 boxes?
> 
For this to work properly on i386 (and x86_64), we will need to
port Matthew's other patch at 
http://marc.theaimsgroup.com/?l=linux-ia64&m0614534704894&w=2
to i386 too. This sets up the bus resources correctly for root
bridges, and is needed for pci_bus_assign_resources() to work
properly.

I can take a crack at doing that, but I'm going to have to hunt
around for an acpiphp capable i386 box too. I will also test this
on a Tiger ia64 box.

Rajesh
