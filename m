From: "Nakajima, Jun" <jun.nakajima@intel.com>
Date: Sat, 13 Mar 2004 01:44:22 +0000
Subject: RE: RE[PATCH]2.6.4-rc3 MSI Support for IA64
Message-Id: <7F740D512C7C1046AB53446D37200173FEB9E0@scsmsx402.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403130008.i2D08SMQ011709@snoqualmie.dp.intel.com>
In-Reply-To: <200403130008.i2D08SMQ011709@snoqualmie.dp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Nguyen, Tom L" <tom.l.nguyen@intel.com>, davidm@hpl.hp.com, Zwane Mwaikambo <zwane@linuxpower.ca>
Cc: long <tlnguyen@snoqualmie.dp.intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, grep@kroah.com, jgarzik@pobox.com, "Luck, Tony" <tony.luck@intel.com>

Long,

I agree with David and Zwane. The other thing is those CONFIG_IA64
below. We should move those to the arch-specific directory, by defining
interface/macro. 

Jun

>-#define MSI_AUTO -1
>+#ifndef CONFIG_IA64
>+#include <asm/desc.h>
>+#ifndef CONFIG_X86_64
>+#include <mach_apic.h>
>+#endif
>
>-#ifndef CONFIG_X86_IO_APIC
>-static inline int get_ioapic_vector(struct pci_dev *dev) { return -1;}
>-static inline void restore_ioapic_irq_handler(int irq) {}
>+static inline int vector_resources(void)
>+{
>+ 	int res;
>+#ifndef CONFIG_IA64
>+ 	int i, repeat;
>+ 	for (i = NR_REPEATS; i > 0; i--) {
>+ 		if ((FIRST_DEVICE_VECTOR + i * 8) > FIRST_SYSTEM_VECTOR)
>+ 			continue;
>+ 		break;
>+ 	}
>+ 	i++;
>+ 	repeat = (FIRST_SYSTEM_VECTOR - FIRST_DEVICE_VECTOR)/i;
>+ 	res = i * repeat - NR_RESERVED_VECTORS + 1;
> #else
>-extern void restore_ioapic_irq_handler(int irq);
>+ 	res = LAST_DEVICE_VECTOR - FIRST_DEVICE_VECTOR - 1;
> #endif
>+
>+ 	return res;
>+}
>
>+#ifdef CONFIG_IA64
>+#define MSI_DEST_MODE			MSI_PHYSICAL_MODE
>+#define MSI_TARGET_CPU	((ia64_getreg(_IA64_REG_CR_LID) >> 16) &
0xffff)
>+#define MSI_TARGET_CPU_SHIFT		4
>+#else
>+#define MSI_DEST_MODE			MSI_LOGICAL_MODE
>+#define MSI_TARGET_CPU_SHIFT		12
> #ifdef CONFIG_SMP
> #define MSI_TARGET_CPU
logical_smp_processor_id()
> #else
> #define MSI_TARGET_CPU			TARGET_CPUS
> #endif
>+#endif

>-----Original Message-----
>From: Nguyen, Tom L
>Sent: Friday, March 12, 2004 4:22 PM
>To: davidm@hpl.hp.com; Zwane Mwaikambo
>Cc: long; linux-ia64@vger.kernel.org; linux-kernel@vger.kernel.org;
>grep@kroah.com; jgarzik@pobox.com; Nakajima, Jun; Luck, Tony
>Subject: RE: RE[PATCH]2.6.4-rc3 MSI Support for IA64
>
>On Fri, 12 Mar 2004, David Mosberger wrote:
>
>>>>>> On Fri, 12 Mar 2004 18:26:39 -0500 (EST), Zwane Mwaikambo
><zwane@linuxpower.ca> said:
>
>>  Zwane> I wonder if we could consolidate these vector allocators as
>>  Zwane> assign_irq_vector(AUTO_ASSIGN) has the same semantics as
>>  Zwane> ia64_alloc_vector() and the one for i386 is also almost the
>>  Zwane> same as its MSI ilk.
>
>> Agreed.  I don't see any reason why ia64_alloc_vector() and
>> assign_irq_vector() couldn't or shouldn't be one and the same thing
>> (and assign_irq_vector() is a fine name).
>
>Agree. Thanks!
>
>> Tom, if you want to send me a patch that converts the existing uses
of
>> ia64_alloc_vector() to assign_irq_vector(), I'd be happy to apply
>> (assuming it's clean etc., as usual).
>
>Thanks! We'll do. I will work with Tony and Jun to consolidate
i386/IA64
>vector
>allocators to ensure it is clean.
>
>Thanks,
>Long
