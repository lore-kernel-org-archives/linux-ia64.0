From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 07 Jan 2005 23:34:31 +0000
Subject: [PATCH] ia64: reset console_loglevel so INIT output always goes to
Message-Id: <1105140871.25267.50.camel@eeyore>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Reset console_loglevel early in INIT handler.  Otherwise, if
it has been turned down (i.e., with "dmesg -n1"), the user may
see no effect at all from issuing an INIT.  We're never going
to run any more user code, so there won't be any opportunity for
anything to collect the output from the dmesg buffer.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

=== arch/ia64/kernel/mca.c 1.71 vs edited ==--- 1.71/arch/ia64/kernel/mca.c	2004-11-11 11:04:30 -07:00
+++ edited/arch/ia64/kernel/mca.c	2005-01-07 16:22:54 -07:00
@@ -1133,6 +1133,7 @@
 	pal_min_state_area_t *ms;
 
 	oops_in_progress = 1;	/* avoid deadlock in printk, but it makes recovery dodgy */
+	console_loglevel = 15;	/* make sure printks make it to console */
 
 	printk(KERN_INFO "Entered OS INIT handler. PSP=%lx\n",
 		ia64_sal_to_os_handoff_state.proc_state_param);


