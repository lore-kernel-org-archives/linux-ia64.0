From: MAEDA Naoaki <maeda.naoaki@jp.fujitsu.com>
Date: Mon, 24 May 2004 02:54:38 +0000
Subject: Re: /proc/ioports regression in 2.6.6 on Tiger4
Message-Id: <20040524.115438.122622110.maeda@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513.182357.104026513.maeda@jp.fujitsu.com>
In-Reply-To: <20040513.182357.104026513.maeda@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, David.

Could you consider to apply this Matthew's patch that fixes the regression
of /proc/ioports? 

Thanks,
Naoaki Maeda

diff -urp a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
--- a/arch/ia64/pci/pci.c	2004-05-13 12:19:52.000000000 -0700
+++ b/arch/ia64/pci/pci.c	2004-05-13 12:21:32.000000000 -0700
@@ -323,8 +323,10 @@ pcibios_fixup_device_resources (struct p
 	struct pci_controller *controller = PCI_CONTROLLER(dev);
 	struct pci_window *window;
 	int i, j;
+	int limit = (dev->hdr_type = PCI_HEADER_TYPE_NORMAL) ? \
+		PCI_ROM_RESOURCE : PCI_NUM_RESOURCES;
 
-	for (i = 0; i < PCI_NUM_RESOURCES; i++) {
+	for (i = 0; i < limit; i++) {
 		if (!dev->resource[i].start)
 			continue;


From: Chris McDermott <lcm@us.ibm.com>
Subject: Re: /proc/ioports regression in 2.6.6 on Tiger4
Date: Thu, 13 May 2004 12:28:37 -0700

> On Thu, May 13, 2004 at 18:23 +0900, MAEDA Naoaki wrote: 
> > Hi, 
> > 
> > Since 2.6.6, "cat /proc/ioports" loops infinity on Tiger4, because 
> > there is a loop in ioport_resource tree.
> > 
> > $ cat /proc/ioports 
> > 00000000-00005fff : PCI Bus 0000:00
> >   00000060-0000006f : i8042
> >   000001f0-000001f7 : ide0
> >   000003c0-000003df : vga+
> >   000003f6-000003f6 : ide0
> >           00000500-0000053f : 0000:00:1f.0
> >           00000500-0000053f : 0000:00:1f.0
> >           00000500-0000053f : 0000:00:1f.0
> >           00000500-0000053f : 0000:00:1f.0
> >           00000500-0000053f : 0000:00:1f.0
> >           00000500-0000053f : 0000:00:1f.0
> >           00000500-0000053f : 0000:00:1f.0
> >           00000500-0000053f : 0000:00:1f.0
> >           00000500-0000053f : 0000:00:1f.0
> >           00000500-0000053f : 0000:00:1f.0
> >           00000500-0000053f : 0000:00:1f.0
> >           00000500-0000053f : 0000:00:1f.0
> >           00000500-0000053f : 0000:00:1f.0
> > 	  ... 
> > 
> > $ /sbin/lspci -vs 00:1f.0
> > 00:1f.0 ISA bridge: Intel Corp. 82801DB LPC Interface Controller (rev 02)
> >         Flags: bus master, medium devsel, latency 0
> > 
> > 0000:00:1f.0, which causes the loop, is an Intel LPC interface bridge,
> > and quirk_ich4_lpc_acpi() has become called for the bridge since 2.6.6.
> > 
> > The reason of the loop is, pci_claim_resource() is issued twice with
> > the exactly same resource structure, the first one is called by 
> > quirk_io_region() for quirk_ich4_lpc_acpi() at pci_fixup_device() and
> > the second one is called by pcibios_fixup_device_resources(), 
> > and in this condition, insert_resource() sets the resource's child pointer
> > to itself. Oviously, it causes the loop.
> 
> Ran into the same problem on an IBM ia64 system (x455). Although, the x455 has 
> a different Southbridge, so the same device was being added to the resource 
> tree twice, from pcibios_fixup_device_resources() and from quirk_io_region() 
> (called from quirk_vt82c686_acpi()), in our case.
> 
> > 
> > There are a few ways to fix the problem as following, but I'm not sure
> > which one is the best. 
> > 
> > 1) Do not claim the resource in quirk_io_region().
> > 2) Put additional check in pcibios_fixup_device_resources() if the resource
> >    has already been claimed.
> > 3) Modify insert_resource() not to claim the resource that has already been
> >    claimed and return with -EBUSY.
> > 
> > Does anybody have comments?
> > 
> 
> Yep, I considered these 3 options, plus a few others. None of the solutions
> seemed very clean, though. In the end I decided to ask Matthew Wilcox about 
> this. He provided the following patch to correct the problem. Please try this
> out and if it works for you, we'll ask David to apply.
> 
> thanks,
> -- 
> -chris
> 
> Chris McDermott
> IBM Linux Technology Center (LTC)
> xSeries Platform Enablement
> lcm@us.ibm.com
> 
> 
> diff -urp a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
> --- a/arch/ia64/pci/pci.c	2004-05-13 12:19:52.000000000 -0700
> +++ b/arch/ia64/pci/pci.c	2004-05-13 12:21:32.000000000 -0700
> @@ -323,8 +323,10 @@ pcibios_fixup_device_resources (struct p
>  	struct pci_controller *controller = PCI_CONTROLLER(dev);
>  	struct pci_window *window;
>  	int i, j;
> +	int limit = (dev->hdr_type = PCI_HEADER_TYPE_NORMAL) ? \
> +		PCI_ROM_RESOURCE : PCI_NUM_RESOURCES;
>  
> -	for (i = 0; i < PCI_NUM_RESOURCES; i++) {
> +	for (i = 0; i < limit; i++) {
>  		if (!dev->resource[i].start)
>  			continue;
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
