From: Greg KH <greg@kroah.com>
Date: Wed, 19 Jan 2005 21:44:58 +0000
Subject: Re: [PATCH] Convert acpiphp to use generic resource code
Message-Id: <20050119214458.GD4151@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050119185120.GE25940@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20050119185120.GE25940@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 19, 2005 at 06:51:20PM +0000, Matthew Wilcox wrote:
> 
> This patch converts acpiphp to use the generic PCI resource assignment
> code.  It's quite large, but most of it is deleting the acpiphp_pci and
> acpiphp_res files.  It's tested on an hp Integrity rx8620 (which won't
> work without this patch).  Testers with other hardware welcomed.

Nice!

Unfortunatly I don't have access to any systems that support acpi pci
hotplug.  Anyone else out there able to test this patch to make sure it
works properly on their i386 boxes?

thanks,

greg k-h
