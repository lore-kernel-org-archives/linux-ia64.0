From: Keith Owens <kaos@sgi.com>
Date: Wed, 06 Apr 2005 03:32:33 +0000
Subject: Re: [patch] add MCA recovery on/off switch
Message-Id: <8782.1112758353@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504060327.j363REMp8976934@clink.americas.sgi.com>
In-Reply-To: <200504060327.j363REMp8976934@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 5 Apr 2005 22:27:14 -0500 (CDT), 
Russ Anderson <rja@sgi.com> wrote:
>Create /proc/sys/kernel/mca_recovery to turn on/off the MCA recovery code.
>This allows the recovery code to be enabled or disabled without having
>to reboot.
>
>1 indicates MCA recovery is on.
>0 indicates MCA recovery is off.
>
>Signed-off-by: Russ Anderson <rja@sgi.com>
>
>------------------------------------------------------------------------------------
>Index: linux/arch/ia64/kernel/mca.c
>=================================>--- linux.orig/arch/ia64/kernel/mca.c	2005-04-01 09:31:54.106157562 -0600
>+++ linux/arch/ia64/kernel/mca.c	2005-04-05 17:29:19.933493325 -0500
>@@ -123,6 +123,8 @@
>  */
> static int cpe_poll_enabled = 1;
> 
>+int mca_recovery = 1;
>+
> extern void salinfo_log_wakeup(int type, u8 *buffer, u64 size, int irqsafe);
> 
> static int mca_init;
>@@ -884,6 +886,7 @@
> 	recover = (psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc))
> 	/* other error recovery */
> 	   || (ia64_mca_ucmc_extension 
>+		&& mca_recovery
> 		&& ia64_mca_ucmc_extension(
> 			IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA),
> 			&ia64_sal_to_os_handoff_state,
>Index: linux/kernel/sysctl.c
>=================================>--- linux.orig/kernel/sysctl.c	2005-04-01 09:34:11.198549062 -0600
>+++ linux/kernel/sysctl.c	2005-04-05 18:10:18.987566865 -0500
>@@ -121,6 +121,8 @@
> extern int acct_parm[];
> #endif
> 
>+extern int mca_recovery;
>+
> int randomize_va_space = 1;
> 
> static int parse_table(int __user *, int, void __user *, size_t __user *, void __user *, size_t,
>@@ -642,7 +644,14 @@
> 		.mode		= 0644,
> 		.proc_handler	= &proc_dointvec,
> 	},
>-
>+	{
>+		.ctl_name	= KERN_MCA_RECOVERY,
>+		.procname	= "mca_recovery",
>+		.data		= &mca_recovery,
>+		.maxlen		= sizeof(int),
>+		.mode		= 0644,
>+		.proc_handler	= &proc_dointvec,
>+	},
> 	{ .ctl_name = 0 }
> };

That is not going to work for other architectures, they will get an
unresolved reference to mca_recovery.

