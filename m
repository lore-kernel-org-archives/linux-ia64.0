From: Keith Owens <kaos@sgi.com>
Date: Tue, 25 Mar 2003 21:15:30 +0000
Subject: Re: [Linux-ia64] ia64_mca_rendez_int_handler use of hard_smp_processor_id
Message-Id: <marc-linux-ia64-105590723705311@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705289@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705289@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 25 Mar 2003 08:45:56 -0800, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>>>>>> On Sat, 22 Mar 2003 15:12:55 +1100, Keith Owens <kaos@sgi.com> >said:
>
>  Keith> arch/ia64/kernel/mca.c:ia64_mca_rendez_int_handler has
>  Keith> #ifdef CONFIG_SMP
>  Keith> cpu = cpu_logical_id(hard_smp_processor_id());
>  Keith> #endif
>  Keith> ia64_mc_info.imi_rendez_checkin[cpu] = >IA64_MCA_RENDEZ_CHECKIN_DONE;
>
>  Keith> All the other code that runs imi_rendez_checkin does so using >logical
>  Keith> cpu numbers.  Why does ia64_mca_rendez_int_handler use that >convoluted
>  Keith> expression instead of the simpler
>  Keith> cpu = smp_processor_id();
>
>  David> I don't know either.  Perhaps the original author remembers >(Jenna or
>  David> Tony, perhaps?).
>
>This code predates me.  I checked with Jenna and she says that it's >before
>her time too.
>
><speculation>
>That convoluted expression avoids use of the per-cpu mapping, but I >can't see
>why we'd be scared to use that here, and not be paranoid elsewhere.  How >was
>smp_processor_id() implemented far back in days of 2.4.0 and before?
></speculation>

At one time there was confusion between which arrays used the logical
cpu number in smp_processor_id() and which arrays used the hardware cpu
number.  This is probably a holdover from that period.

Index: 20.5/arch/ia64/kernel/mca.c
--- 20.5/arch/ia64/kernel/mca.c Wed, 11 Dec 2002 20:58:53 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.3 644)
+++ 20.5(w)/arch/ia64/kernel/mca.c Wed, 26 Mar 2003 08:14:29 +1100 kaos (linux-2.4/s/c/5_mca.c 1.1.3.2.3.1.1.1.1.3 644)
@@ -640,13 +640,10 @@ ia64_mca_wakeup_all(void)
 void
 ia64_mca_rendez_int_handler(int rendez_irq, void *arg, struct pt_regs *ptregs)
 {
-	int flags, cpu = 0;
+	int flags, cpu = smp_processor_id();
 	/* Mask all interrupts */
 	save_and_cli(flags);
 
-#ifdef CONFIG_SMP
-	cpu = cpu_logical_id(hard_smp_processor_id());
-#endif
 	ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_DONE;
 	/* Register with the SAL monarch that the slave has
 	 * reached SAL


