From: "Sluder, Charles" <Charles.Sluder@UNISYS.com>
Date: Wed, 16 Jan 2002 18:47:37 +0000
Subject: RE: [Linux-ia64] [BUG] Interrupt source override (Re: ACPI power
Message-Id: <marc-linux-ia64-105590698805849@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805843@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805843@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We have similar problems with the IRQ overrides on our CMP and NUMA systems.
Our system does not have integrated legacy hardware. Instead we insert a
legacy IO card into a modified PCI slot. THE PCI bus uses IRQ0 - IRQ11 for
the PCI slots and if the legacy card is present then IRQ12 - IRQ20 are used
for the legacy devices and IRQ overrides are used to redirect the IRQs. 

One problem we have is that the existing code gives the legacy vectors away
to the PCI interrupts and then when the overrides are processed the legacy
IRQs reclaim their vectors, resulting in conflicts between PCI and ISA.

The fix we put in is similar to yours with the addition of the change below.

If the legacy card is present (pcat_compat is set) and the PCI interrupt is
in the range of the legacy interrupts then we mark the irq as unused. This
will prevent the vector from being found by iosapic_irq_to_vector(). This
forces a new vector to be assigned to the PCI irq and leaves the vector free
to be reclaimed when the IRQ override is processed.

Chuck Sluder
Unisys Corp.

-- linux-2.4.16/arch/ia64/kernel/iosapic.c     Fri Nov  9 15:26:17 2001
+++ linux/arch/ia64/kernel/iosapic.c    Sun Jan 13 15:45:28 2002
@@ -544,15 +547,16 @@
                        /* the interrupt route is for another controller...
*/
                        continue;

-               if (pcat_compat && (irq < 16))
+               if (pcat_compat && (irq < 16)){
                        vector = isa_irq_to_vector(irq);
-               else {
-                       vector = iosapic_irq_to_vector(irq);
-                       if (vector < 0)
-                               /* new iosapic irq: allocate a vector for it
*/
-                               vector = ia64_alloc_irq();
+                       iosapic_irq[vector].pin = -1;   /* mark as unused */
                }

+               vector = iosapic_irq_to_vector(irq);
+               if (vector < 0)
+                       /* new iosapic irq: allocate a vector for it */
+                       vector = ia64_alloc_irq();
+
                iosapic_irq[vector].addr     = addr;
                iosapic_irq[vector].base_irq = base_irq;
                iosapic_irq[vector].pin      = (irq - base_irq);

-----Original Message-----
From: KOCHI, Takayoshi [mailto:t-kouchi@mvf.biglobe.ne.jp]
Sent: Tuesday, January 15, 2002 8:03 PM
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] [BUG] Interrupt source override (Re: ACPI power
button events)


On BigSur, there's an interrupt source override record for IRQ9 (SCI)
in ACPI table and the kernel should set it correct.
But the current code doesn't reprogram IO-SAPIC correctly and set
interrupt handler type, so the SCI interrupts were never delivered
to running CPUs.

This patch fixes this problem.  This is against 2.4.17 + 011226 ia64
patch (only affects arch/ia64/kernel/iosapic.c and acpi.c).

And with this patch, I can cat /proc/acpi/event and see
"button power 00000080 00000000" now!

On Mon, 14 Jan 2002 16:04:28 -0800
"KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp> wrote:

> Oh well, our BigSur says
> 
>  39:	0	0   IO-SAPIC-edge  acpi
> 
> But ACPI specification says the SCI (ACPI interrupt) should be
> active low, level and shareable.  I'll look into it...

The spec says active low, but the trigger mode is actually
platform-dependent.  BigSur and AzusA defines IRQ9 override
as active-high.
Anyway we should obey what the interrupt override record says...

Thanks,
-- 
KOCHI Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>

