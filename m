From: Keith Owens <kaos@sgi.com>
Date: Wed, 26 Mar 2003 02:13:01 +0000
Subject: [Linux-ia64] Re: ia64_mca_rendez_int_handler use of hard_smp_processor_id
Message-Id: <marc-linux-ia64-105590723705313@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 26 Mar 2003 12:55:55 +1100, 
Peter Chubb <peter@chubb.wattle.id.au> wrote:
>Index: 20.5/arch/ia64/kernel/mca.c
>--- 20.5/arch/ia64/kernel/mca.c Wed, 11 Dec 2002 20:58:53 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.3 644)
>+++ 20.5(w)/arch/ia64/kernel/mca.c Wed, 26 Mar 2003 08:14:29 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.3 644)
>@@ -640,13 +640,10 @@ ia64_mca_wakeup_all(void)
> void
> ia64_mca_rendez_int_handler(int rendez_irq, void *arg, struct pt_regs *ptregs)
> {
>-	int flags, cpu = 0;
>+	int flags, cpu = smp_processor_id();
> 	/* Mask all interrupts */
> 	save_and_cli(flags);
>
>If this is called from a preemptible context, then move the cpu >cmp_processor_id() within the save_and_cli() section, or it won't be
>preempt safe.  (thread could be migrated between getting the processor
>ID and stopping interrupts.)

2.4, preempt is not my problem :).  In any case, MCA rendezvous is a
normal interrupt

  ivt.S:interrupt ->
    ia64_handle_irq ->
      ia64_mca_rendez_int_handler.

It is my understanding that the interrupt handler will not migrate off
the current cpu, even with preempt.


