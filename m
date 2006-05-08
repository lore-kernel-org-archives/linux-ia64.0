From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 08 May 2006 14:51:41 +0000
Subject: Re: [IA64] rework memory attribute aliasing
Message-Id: <200605080851.41136.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605051719.50884.bjorn.helgaas@hp.com>
In-Reply-To: <200605051719.50884.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sunday 07 May 2006 20:42, KAMEZAWA Hiroyuki wrote:
> At memory hotplug, efi information cannot be updated. In -mm kernel,
> hot added memory is registed to /proc/iomem (iomem_resouce).
> 
> Can't we able to write kern_mem_attribute() by using kernel/resouce.c ?
> (add new flag if needed..)
> 
> Now,  efi_initialize_iomem_resources() already registers efi information to 
> iomem_resource.

I didn't address hot-plug memory at all.  You're right that something
should be done in that area.  I don't know enough about memory hotplug
to do anything useful myself, though.
