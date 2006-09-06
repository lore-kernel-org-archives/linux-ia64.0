From: Keith Owens <kaos@sgi.com>
Date: Wed, 06 Sep 2006 04:47:51 +0000
Subject: Re: [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <12211.1157518071@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <75C6D0E56B35AEindou.takao@jp.fujitsu.com>
In-Reply-To: <75C6D0E56B35AEindou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Takao Indoh (on Tue, 05 Sep 2006 21:18:39 +0900) wrote:
>Hi,
>
>Here is the IA64 kdump patch for INIT against 2.6.18-rc5
>with a kexec/kdump 2.6.18-rc5 patch which was posted by Zou Nan hai on 29th Aug.
>
>This patch includes the following two functions.
>
>1) Stop each cpu using INIT interruption
>
>Current kdump uses simple IPI to stop cpus, so cpu does not stop
>if the cpu disables interruption. INIT interruption is non-maskable and
>it can stop cpus surely.

You will get better results if you send a normal IPI first, wait a bit,
then send a non-maskable INIT to just those cpus that have not
responded.  Why?  Because INIT can catch the target cpu in any state,
including down in prom in physical mode or in the assembler code that
is busy saving the registers.  At that point you can forget about
getting any useful backtrace on that cpu.  Sending a normal IPI first
gives the target cpu a chance to get out of any critical section which
gives you a much better backtrace.

KDB has been using the dual interrupt method since March 2006 and it
has significantly improved the diagnostics.  I am happy to work on
common code that can be used by both kdump and kdb to handle stuck cpus
and still get a reasonable backtrace.


All the code below should be under if (!sos->monarch).  INIT sent via
IA64_IPI_DM_INIT should always appear as a slave cpu, not as a monarch.
If the prom is broken so it treats IA64_IPI_DM_INIT as a monarch then
the event needs to be demoted to a slave.  The code sending the INIT
has to be treated as the monarch, anything else will confuse the code
in mca.c that handles the NMI button.  Again, KDB already handles this
case and I am happy to work on common code for both kdb and kexec.

None of the crash dump code should not be inline in mca.c.  It should
be invoked via notify_die(DIE_INIT_SLAVE_PROCESS) so we do not clutter
up mca.c with add ons like debuggers and crash dump handlers.  kdb is
not clean in that regard, but it is on my TODO list to remove all
explicit references to kdb from mca.c.  Using the notify_die() callback
makes mca.c less confusing and cleanly separates any additional code
from the already complex MCA/INIT code.

>+#ifdef CONFIG_CRASH_DUMP
>+	/* if reason code is not 1(reason code 1 means machine check
>+	 * rendezvous), INIT was issued by kdump or INIT button.
>+	 */
>+	if (sos->rv_rc != 1 && (kdump_send_ipi || kdump_on_init)) {
>+		local_irq_disable();
>+		set_curr_task(cpu, previous_current);

set_curr_task() is not a good idea here.  If the original stack was
undefined (e.g. interrupt in physical state or kernel stack overflow)
then you are switching back to garbage.  Do kexec using the clean INIT
stack.  That adds a bit of processing to get the original stack for
backtrace but it is far safer than assuming that the original stack is
useable.

>+		/* change region of gp to region5 */
>+		asm volatile ("movl gp=__gp"::: "memory");

Why?  gp is already pointing at the kernel code before we enter
ia64_init_handler().

>+		crash_kexec(regs);
>+
>+		crash_save_this_cpu();
>+		for (;;)
>+			ia64_hint(ia64_hint_pause);

cpu_relax() is the preferred method.

>--- linux-2.6.18-rc5.org/arch/ia64/kernel/smp.c	2006-08-31 14:27:10.000000000 +0900
>+++ linux-2.6.18-rc5/arch/ia64/kernel/smp.c	2006-09-05 11:39:33.000000000 +0900
>@@ -261,10 +261,17 @@ send_IPI_self (int op)
> }
> 
> #ifdef CONFIG_CRASH_DUMP
>+int kdump_send_ipi = 0;

kdump_on_init should be here, not in mca.c.  In fact there should be no
references to kdb or kexec in mca.c, it should all be handled by local
code that is invoked via notify_die().

> kdump_smp_send_stop()
> {
>- 	send_IPI_allbutself(IPI_KDUMP_CPU_STOP);
>+	unsigned int i;
>+
>+	kdump_send_ipi = 1;

Needs memory barrier here.

>+	for_each_online_cpu (i) {
>+		if (i != smp_processor_id())
>+			platform_send_ipi(i, IA64_IPI_VECTOR, IA64_IPI_DM_INIT, 0);
>+	}
> }

>diff -Nurp linux-2.6.18-rc5.org/kernel/sysctl.c linux-2.6.18-rc5/kernel/sysctl.c
>--- linux-2.6.18-rc5.org/kernel/sysctl.c	2006-08-31 14:27:40.000000000 +0900
>+++ linux-2.6.18-rc5/kernel/sysctl.c	2006-09-05 20:51:37.000000000 +0900
>@@ -45,6 +45,7 @@
> #include <linux/syscalls.h>
> #include <linux/nfs_fs.h>
> #include <linux/acpi.h>
>+#include <linux/kexec.h>
> 
> #include <asm/uaccess.h>
> #include <asm/processor.h>
>@@ -701,6 +702,16 @@ static ctl_table kern_table[] = {
> 		.proc_handler	= &proc_dointvec,
> 	},
> #endif
>+#if defined(CONFIG_IA64) && defined(CONFIG_CRASH_DUMP)
>+	{
>+		.ctl_name	= KERN_KDUMP_ON_INIT,
>+		.procname	= "kdump_on_init",
>+		.data		= &kdump_on_init,
>+		.maxlen		= sizeof (int),
>+	 	.mode		= 0644,
>+		.proc_handler	= &proc_dointvec,
>+	},
>+#endif
> 
> 	{ .ctl_name = 0 }
> };

Do not update sysctl.c.  Use register_sysctl_table() instead.

As I say, kdb has already solved this problem and I want to work on
common code to be used by debuggers and crash dumpers.  I am travelling
until September 15 so my machine access is limited right now.  I can do
an example patch that moves all of kdb mca/init handling to use
notify_die(), but I will not be able to test the patch.

