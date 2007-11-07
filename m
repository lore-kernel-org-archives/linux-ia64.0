From: Alex Williamson <alex.williamson@hp.com>
Date: Wed, 07 Nov 2007 15:14:19 +0000
Subject: Re: [PATCH] Move dmi_scan_machine() call ealier
Message-Id: <1194448459.6463.12.camel@lappy>
List-Id: <linux-ia64.vger.kernel.org>
References: <1194370267.31834.176.camel@bling>
In-Reply-To: <1194370267.31834.176.camel@bling>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Wed, 2007-11-07 at 16:15 +0900, Simon Horman wrote:
> On Tue, Nov 06, 2007 at 10:31:07AM -0700, Alex Williamson wrote:
> > 
> >    I'd like to move our call to dmi_scan_machine up earlier in the boot
> > process so that we can take advantage of a DMI hook, called out of
> > acpi_early_init, to enable _OSI(Linux) on Xen HVM domains.  Since the
> > SMBIOS parsing makes use of ioremap, which Bjorn pointed out is fragile
> > early in boot, I'm reluctant to move this too much earlier.  Given those
> > restrictions, it seems best to simply move this up into our check_bugs
> > function.  Since the DMI hooks are mainly used for adjusting code path
> > based on platform, it doesn't seem like such an unreasonable place to
> > set it up.  Please let me know if you have comments.  Thanks,
> 
> I guess if that works then its ok. But if a name is worth anything,
> I don't think check_bugs() really encompases the behaviour of
> run_dmi_scan().
> 
> Also, you should probably fix up the comment in run_dmi_scan()
> that says it is run as a core_initcall().

   Thanks for the review Simon.  Is the patch below more like what
you're thinking?  I agree that check_bugs doesn't initial seem like the
most appropriate place to setup DMI, but think about what DMI is
typically used for in the kernel.  Mostly quirks and identifying systems
that need something special.  Without creating a safer early ioremap,
the range of places to call this is fairly small.  If you see a better
spot, please suggest it.  I'm not sure what an early ioremap should look
like on ia64 to deal with all the cases that our normal ioremap does.
Thanks,

	Alex


Signed-off-by: Alex Williamson <alex.williamson@hp.com>
--

diff -r 99bc021994c4 arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	Tue Nov 06 22:01:11 2007 +0000
+++ b/arch/ia64/kernel/setup.c	Wed Nov 07 08:00:23 2007 -0700
@@ -982,11 +982,5 @@ check_bugs (void)
 {
 	ia64_patch_mckinley_e9((unsigned long) __start___mckinley_e9_bundles,
 			       (unsigned long) __end___mckinley_e9_bundles);
-}
-
-static int __init run_dmi_scan(void)
-{
 	dmi_scan_machine();
-	return 0;
-}
-core_initcall(run_dmi_scan);
+}
diff -r 99bc021994c4 drivers/firmware/dmi_scan.c
--- a/drivers/firmware/dmi_scan.c	Tue Nov 06 22:01:11 2007 +0000
+++ b/drivers/firmware/dmi_scan.c	Wed Nov 07 08:00:23 2007 -0700
@@ -302,8 +302,8 @@ void __init dmi_scan_machine(void)
 		if (efi.smbios = EFI_INVALID_TABLE_ADDR)
 			goto out;
 
-		/* This is called as a core_initcall() because it isn't
-		 * needed during early boot.  This also means we can
+		/* This is called later in bootup, when normal
+		 * ioremap is available.  This means we can
 		 * iounmap the space when we're done with it.
 		 */
 		p = dmi_ioremap(efi.smbios, 32);


