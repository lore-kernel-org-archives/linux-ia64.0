From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 08 May 2006 02:42:54 +0000
Subject: Re: [IA64] rework memory attribute aliasing
Message-Id: <20060508114254.8e1e932a.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605051719.50884.bjorn.helgaas@hp.com>
In-Reply-To: <200605051719.50884.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 5 May 2006 17:19:50 -0600
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:

> This closes a couple holes in our attribute aliasing avoidance scheme:
> 
>   - The current kernel fails mmaps of some /dev/mem MMIO regions because
>     they don't appear in the EFI memory map.  This keeps X from working
>     on the Intel Tiger box.
> 
>   - The current kernel allows UC mmap of the 0-1MB region of
>     /sys/.../legacy_mem even when the chipset doesn't support UC
>     access.  This causes an MCA when starting X on HP rx7620 and rx8620
>     boxes in the default configuration.
> 
> There's more detail in the Documentation/ia64/aliasing.txt file this
> adds, but the general idea is that if a region might be covered by
> a granule-sized kernel identity mapping, any access via /dev/mem or
> mmap must use the same attribute as the identity mapping.
> 
> Otherwise, we fall back to using an attribute that is supported
> according to the EFI memory map, or to using UC if the EFI memory
> map doesn't mention the region.
> 
> Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
> 
At memory hotplug, efi information cannot be updated. In -mm kernel,
hot added memory is registed to /proc/iomem (iomem_resouce).

Can't we able to write kern_mem_attribute() by using kernel/resouce.c ?
(add new flag if needed..)

Now,  efi_initialize_iomem_resources() already registers efi information to 
iomem_resource.

-Kame

