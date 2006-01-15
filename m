From: John Keller <jpk@sgi.com>
Date: Sun, 15 Jan 2006 16:45:27 +0000
Subject: Re: [PATCH] SN: Add initial ACPI support
Message-Id: <200601151645.k0FGjSxJ290162@fcbayern.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <28961.1137282162@ocs3.ocs.com.au>
In-Reply-To: <28961.1137282162-1LO6/iIh+iQ0n/F98K4Iww@public.gmane.org> from "Keith Owens" at Jan 15, 2006 10:42:42 AM
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos-sJ/iWh9BUns@public.gmane.org>
Cc: John Keller <jpk-sJ/iWh9BUns@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

> 
> John Keller (on Sat, 14 Jan 2006 11:37:47 -0600 (CST)) wrote:
> >First phase in introducing ACPI support to SN.
> 
> >Index: acpi_support/arch/ia64/sn/kernel/io_init.c
> >=================================> >--- acpi_support.orig/arch/ia64/sn/kernel/io_init.c	2006-01-14 09:26:29.761674100 -0600
> >+++ acpi_support/arch/ia64/sn/kernel/io_init.c	2006-01-14 09:45:06.418505048 -0600
> 
> >+#define SN_ACPI_BASE_SUPPORT (acpi_gbl_DSDT->oem_revision >= 0x20101)
> 
> These mini tests are conventionally defined as pseudo functions, i.e.
> #define SN_ACPI_BASE_SUPPORT() ...

OK, I'll make that change.


> 
> >+static void __init sn_acpi_setup(void);
> 
> Forward declarations do not include __init/__exit etc.  I know that the
> kernel has several examples of this, but they are wrong.

OK.


> 
> > static struct list_head sn_sysdata_list;
> > 
> >@@ -157,26 +162,96 @@
> 
> Patches look nicer with function names in the '@@' line.
> export QUILT_DIFF_OPTS=-p in ~/.bashrc.

Shall do.


> 
> >+inline uint64_t
> >+sal_ioif_init(void)
> 
> Make that static with no inline, let gcc decide if it should be inlined
> or not.

OK.


> 
> >+	struct ia64_sal_retval ret_stuff;
> >+	ret_stuff.status = 0;
> >+	ret_stuff.v0 = 0;
> >+
> >+	SAL_CALL_NOLOCK(ret_stuff,
> >+			(u64) SN_SAL_IOIF_INIT,
> >+			0, 0, 0, 0, 0, 0, 0);
> 
> Is that really meant to be a NOLOCK call?  Can SAL cope with another
> SAL call being executed at the same time as SN_SAL_IOIF_INIT?

I'll check on this. 


> 
> +static void __init
> +sn_hubdev_init(struct hubdev_info *hubdev)
> +{
> +
> +	struct sn_flush_device_list *sn_flush_device_list;
> 
> sn_flush_device_list no longer exists.  Prarit Bhargava changed it in
> https://www.redhat.com/archives/fedora-devel-list/2006-January/msg00123.html
> and that patch is now in the IA64 git tree.

See below.


> 
> >+	if (!hubdev->hdi_flush_nasid_list.widget_p)
> >+		return;
> >+
> >+	hubdev->hdi_flush_nasid_list.widget_p > >+	    kmalloc((HUB_WIDGET_ID_MAX + 1) *
> >+		    sizeof(struct sn_flush_device_list *), GFP_KERNEL);
> 
> Overwriting hubdev->hdi_flush_nasid_list.widget_p only if it is already
> set does not look right.  Should the test be this?

I believe this is correct. It is checking if the PROM had setup
any flush list info, and if so will setup/alloc kernel space, and make a SAL call to get flush info.

Note that this code is not new, but has just been moved to a
common routine that the ACPI and non-ACPI code paths can use.
(sn_fixup_ionodes() and sn_hubdev_add())


> 
> 	if (hubdev->hdi_flush_nasid_list.widget_p)
> 		return;
> 
> >+	memset(hubdev->hdi_flush_nasid_list.widget_p, 0x0,
> >+	       (HUB_WIDGET_ID_MAX + 1) *
> >+	       sizeof(struct sn_flush_device_list *));
> 
> You memset hubdev->hdi_flush_nasid_list.widget_p without testing if
> kmalloc succeeded :(.

OK.


> 
> BTW, replace all occurrences of kmalloc + memset with kzalloc.
> 
> >+	for (widget = 0; widget <= HUB_WIDGET_ID_MAX; widget++) {
> >+		sn_flush_device_list = kmalloc(DEV_PER_WIDGET *
> >+					       sizeof(struct
> >+						      sn_flush_device_list),
> >+					       GFP_KERNEL);
> >+		memset(sn_flush_device_list, 0x0,
> >+		       DEV_PER_WIDGET *
> >+		       sizeof(struct sn_flush_device_list));
> 
> Missing test if kmalloc succeeded.
> 

OK.


> >+		status = sal_get_widget_dmaflush_list(hubdev->hdi_nasid, widget,
> >+						 (uint64_t)
> >+						 __pa (sn_flush_device_list));
> >+		if (status) {
> >+			kfree(sn_flush_device_list);
> >+			return;
> >+		}
> >+
> >+		spin_lock_init(&sn_flush_device_list->sfdl_flush_lock);
> 
> The spinlock was moved out of sn_flush_device_list to its own
> structure, so the prom is not exposed to changes in the size of kernel
> structures.  You need to (a) change sn_flush_device_list to
> sn_flush_device_common and (b) allocate the related
> sn_flush_device_kernel and format it.
> 
> At this point the patch does not make any sense.  It only applies over
> the top of Prarit's patch (i.e. against a recent ia64 git tree), but
> you are deleting all the sn_flush_device_kernel code that Prarit
> recently added and appear to be going back to the old
> sn_flush_device_list code that Prarit removed because it broke the
> prom.
> 


Yes. It appears that I mistakenly sent out the pre-merge version
of my patch. I have no intention of changing any of Prarit's code.
Odds are I copied the patch and sent it out before I did a 'refresh'.
:-(
I'll re-post the patch shortly.

John
----
