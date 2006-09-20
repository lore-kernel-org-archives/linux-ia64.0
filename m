From: Bob Montgomery <bob.montgomery@hp.com>
Date: Wed, 20 Sep 2006 18:50:27 +0000
Subject: Re: [Patch] IA64 Kexec/Kdump patch for 2.6.18-rc6
Message-Id: <1158778227.10115.114.camel@amd.troyhebe>
List-Id: <linux-ia64.vger.kernel.org>
References: <1158288948.2591.195.camel@linux-znh>
In-Reply-To: <1158288948.2591.195.camel@linux-znh>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2006-09-15 at 10:55 +0800, Zou Nan hai wrote:
> Hi,
>    Here is a new version of IA64 Kexec/Kdump patch.
>    Update since last patch.
> 
>    1. Ignore offset in crashkernel=size@offset kernel parameter. kernel
> will find crashkernel region according to size at boot time. However
> crashkernel parameter format is not changed to keep compatibility with
> other archs
>    2. send EOI to iosapic
>    3. Patch from HP to clean interrupt at shutdown time.
>    4. Enhanced OS_INIT handle patch base on Takao Indoh	and comments
> from Keith Owens.	

This patch fails our buncho read_oops_irq test because of this change
(as displayed in Horms' incremental patch):

@@ -113,11 +121,104 @@
         * In practice this means shooting down the other cpus in
         * an SMP system.
         */
-       if (in_interrupt())
-               ia64_eoi();
-       device_shootdown();
+       kexec_disable_iosapic();
 #ifdef CONFIG_SMP

Our read_oops_irq test attempts to simulate an oops from an interrupt
handler by sending an IPI to a processor and having it generate an oops
from within the handler.   With the new patch we see this:

...
  <0>Kernel panic - not syncing: Aiee, killing interrupt handler!
 Linux version 2.6.18-rc6-15sep (bobm@hpde-erix2) (gcc version 3.3.5
(Debian 1:3.3.5-12)) #9 SMP Wed Sep 20 20:09:10 MDT 2006
Ignoring memory below 128MB
Ignoring memory above 384MB
EFI v1.10 by HP: SALsystab=0x3ee7a000 ACPI 2.0=0x3fe34000
SMBIOS=0x3ee7c000 HCDP=0x3fe32000
booting generic kernel on platform dig
PCDP: v3 at 0x3fe32000
Early serial console at MMIO 0xf4050000 (options '9600n8')
SAL 3.1: HP version 1.11
SAL Platform features: None
SAL: AP wakeup using external interrupt vector 0xff
BUG: warning at arch/ia64/kernel/sal.c:251/check_sal_cache_flush()

(and then the console hangs)

Upon reboot, the crash_kexec'd system BUGs and hangs in
check_sal_cache_flush because ia64_get_ivr returns
IA64_SPURIOUS_INT_VECTOR instead of the expected IA64_TIMER_VECTOR.  I
believe it does this because the processor still has an in-service flag
for the IPI interrupt because the handler dies before doing an
ia64_eoi().

The old kdump patch checked in_interrupt(), a software construct that
keeps track of interrupt nesting, I think, and executed an ia64_eoi() if
nonzero.  But that got removed in this new patch, leading to our test
failures.

The old code wasn't really correct because it only issued one
ia64_eoi(). Because of the capability of nesting interrupts, it should
be possible to have either 16 (priority classes?) or 256 - 16
(prioritized interrupt vectors?) levels of nested interrupt at the time
of the crash.  Which is it?  Do we believe this comment in
arch/ia64/kernel/irq_ia64.c?

        /*
         * Always set TPR to limit maximum interrupt nesting depth to
         * 16 (without this, it would be ~240, which could easily lead
         * to kernel stack overflows).
         */

We might be able to trust the software in_interrupt mechanism and count
it down to issue ia64_eoi's, but it seems that it's just as easy on our
way down to issue a bunch of ia64_eoi's equal to the maximum possible
nesting level.  I can't see any indication in the docs that it's bad to
do ia64_eoi if an interrupt is not currently in-service.  

This has to occur before the pending interrupt clearing loop done in
ia64_machine_kexec, because any in_service interrupts could cause this
loop to terminate early with the IA64_SPURIOUS_INT_VECTOR also,
rendering it ineffective:

        /* unmask TPR and clear any pending interrupts */
        ia64_setreg(_IA64_REG_CR_TPR, 0);
        ia64_srlz_d();
        vector = ia64_get_ivr();
        while (vector != IA64_SPURIOUS_INT_VECTOR) {
                ia64_eoi();
               vector = ia64_get_ivr();
        }

My prosposed fix appears below:

Bob Montgomery
Working at HP


--- linux-2.6.18-rc6-15sep/arch/ia64/kernel/machine_kexec.c.orig        2006-09-19 10:17:48.000000000 -0600
+++ linux-2.6.18-rc6-15sep/arch/ia64/kernel/machine_kexec.c     2006-09-20 20:36:21.000000000 -0600
@@ -94,6 +94,7 @@ static void ia64_machine_kexec(struct un
        void *pal_addr = efi_get_pal_addr();
        unsigned long code_addr = (unsigned long)page_address(image->control_code_page);
        unsigned long vector;
+       int ii;

        if (image->type = KEXEC_TYPE_CRASH) {
                crash_save_this_cpu();
@@ -112,6 +113,10 @@ static void ia64_machine_kexec(struct un
        ia64_set_lrr0(1 << 16);
        ia64_set_lrr1(1 << 16);

+       /* terminate possibly nested in-service interrupts */
+       for (ii = 0; ii < 16; ii++)
+               ia64_eoi();
+
        /* unmask TPR and clear any pending interrupts */
        ia64_setreg(_IA64_REG_CR_TPR, 0);
        ia64_srlz_d();



 


