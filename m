From: "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp>
Date: Fri, 02 Aug 2002 17:45:11 +0000
Subject: Re: [Linux-ia64] [PATCH] dynamic IRQ allocation
Message-Id: <marc-linux-ia64-105590701905887@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905851@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905851@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 1 Aug 2002 23:04:29 -0700
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> The patch basically looks fine to me, except for some naming issues.
> We now have vectors, global vectors, global system interrupts (GSIs),
> irq numbers, and what not.  This is confusing and hard to maintain.
> We should settle on a consistent set of names (hopefully something
> consistent with Linux, ACPI spec, and PCI spec).  I tried to do this a
> while ago (see big comment at the beginning of iosapic.c), but the
> picture described there is incomplete for large machines and doesn't
> do a good job at integrating with ACPI lingo.  Anyone want to take a
> stab?

Bjorn, David, I checked related documents.

* _PRT (ACPI2.0a, p.149)
|  An object that specifies the PCI interrupt Routing Table.
  Linux: pci_irq (iosapic.c)
         acpi_prt (ACPI, arch/ia64/acpi.c)
         struct pci_vector_struct (asm-ia64/system.h)
  Note: pci_irq and acpi_prt are almost identical.

* Global System Interrupts (ACPI2.0a, p.125, 32bit)
|  Global System Interrupts can be thought of as ACPI Plug and
|  Play IRQ numbers. They are used to virtualize interrupts in tables
|  and in ASL methods that perform resource allocation of interrupts.
|  Do not confuse global system interrupts with ISA IRQs although in
|  the case of the IA-PC 8259 interrupts they correspond in a one-to-one
|  fashion.
  Linux: global_vector (iosapic.c)
         irq (used as an argument for find_iosapic() etc. in iosapic.c)

* Global System Interrupt Base (ACPI2.0a, p.122, 32bit)
|  The global system interrupt number where this I/O SAPIC's
|  interrupt inputs start. The number of interrupt inputs is
|  determined by the I/O SAPIC's Max Redir Entry register.
  Linux: base_irq in struct iosapic_irq/iosapic (iosapic.c)

* Bus-relative interrupt source (IRQ) (ACPI2.0a, p.119, Table 5-20)
|  For example, if your machine has the ISA Programmable Interrupt
|  Timer (PIT) connected to ISA IRQ 0, but in APIC mode, it is
|  connected to I/O APIC interrupt input 2, then you would need an
|  Interrupt Source Override where the source entry is `0' and
|  the Global System Interrupt is `2.'
  Linux: irq (iosapic.c::iosapic_init())
         isa_irq_to_vector (iosapic.c, irq_ia64.c etc.)
         legacy_irq (iosapic.c::iosapic_register_legacy_irq())

* Address (ACPI2.0a, p.164, _PRT, 32bit)
|  The address of the device (uses the same format as _ADR).
  Linux: pci_id in struct pci_vector_struct (asm-ia64/system.h)

* Pin (ACPI2.0a, p.164, _PRT, 8bit)
|  The PCI pin number of the device (0?INTA, 1?INTB, 2?INTC, 3?INTD).
  Linux: pin in struct pci_vector_struct (asm-ia64/system.h)

* Source (ACPI2.0a, p.164, _PRT, String or NULL)
|  String Name of the device that allocates the interrupt to which
|  the above pin is connected . If this field is NULL, then the
|  interrupt is allocated from the global interrupt pool.
  Not used

* Source Index (ACPI2.0a, p.164, _PRT, 32bit)
|  Index that indicates which resource descriptor in the resource
|  template of the device pointed to in the Source field this
|  interrupt is allocated from. If the Source field is null,
|  this field is the global system interrupt number to which
|  the pin is connected.
  Linux: irq in struct pci_vector_struct (asm-ia64/system.h)
         iosapic_irq (iosapic.c)

* MAX REDIR (460GX SDM, p.2-49, 8bit)
|  This is entry number (0 being the lowest entry) of the highest
|  entry in the I/O RT. It is equal to the number of interrupt
|  input pins minus one that the PID supports. This field is
|  hardwired and is read-only. The PID sets this field to 3FH,
|  indicating that it supports 64 RTEs.
  Linux: max_pin (iosapic.c)

* Interrupt Pin (PCI2.2, p.200, 8bit)
|  The Interrupt Pin register tells which interrupt pin the device
|  (or device funtion) uses. A value of 1 corresponds to INTA#.
  Linux: pci_pin (iosapic.c::pci_pin_to_vector())
         pin (iosapic.c)


...

While looking up these words in specs, I found that no one is
using the term 'global vector' except us:)

Confusing words are: irq, vector, pin.

IRQ:
 Top comment in iosapic.c clarifies that

 "outside this module, IA-64 vectors are called "irqs".
  This is because the traditional name Linux uses for interrupt vectors"

 but we can see much confusion here and there in iosapic.c.

 Now we have to realize that IRQ means "an identifier for interrupt
 in a Linux system".  But ISA IRQ is only exception for this.
 Perhaps we should use "isa_irq" for naming.

 So except IRQ handler routines (which are called via
 irq_type_iosapic_{level,edge}), and isa_irq related routines,
 all "*irq*" have to be renamed.

 Also note that we are using one-to-one mapping between
 IRQ and VECTOR (for DIG platform), which is source of
 confusion and bugs.
 For example, most IRQ handler routines call irq_to_vector()
 to convert from IRQ to VECTOR, but iosapic_set_affinity()
 doesn't.  In set_rte(), set_irq_affinity_info() is called
 with VECTOR as 1st argument, but it should be IRQ.

 "iosapic irq", "global vector" and "global system interrupt" are same!
 gsi_to_vector() was totally wrong thing.
 But as "iosapic irq" and "global vector" are not used
 elsewhere, all usage should be corrected to "global system interrupt".

VECTOR:
 'Vector' is relatively consistently used in iosapic.c.
 vector should be used only for ia64 interrupt vector.
 'global_vector' must not be used:)
 For iosapic_register_platform_irq(), the second argument
 should be just "vector" instead of "global_vector" and
 the third argument is "gsi".

PIN:
 'pin' is used for PCI interrupt pin (INTA, INTB...) and 
 IOSAPIC interrupt input pin.  Probably calling the former
 'pci_pin' is enough.  For more clarification, IOSAPIC
 pin can be called 'rte_index'.

 "max_pin" may be named "max_redir" if you prefer
 exact match with the specification.  But the content
 is somewhat confusing for most C programmers, because
 it represents the highest number of pins (0 origin)
 and not the number of pins.  There were a couple of
 bugs in the past regarding this.  So we could use "num_rte"
 (by adding 1 to max_redir) for future bug-proof.

These are my idea how to rename variable/function names:

 pci_irq -> remove (use "acpi_prt" directly?)
 iosapic_irq -> iosapic_intr_info
 base_irq -> gsi_base
 irq -> gsi (where appropriate)
 irq -> isa_irq (where appropriate)
 irq_type -> as it is
      (including no_irq_type, irq_type_iosapic_{level,edge},
       irq_type_ia64_lsapic)
 iosapic_irq_to_vector() -> gsi_to_vector()
       (Note: old gsi_to_vector() is wrongly implemented)

 register_irq() -> register_intr()
      (including iosapic_register_irq(), 
                 iosapic_register_platform_irq())
 iosacpic_register_legacy_irq() -> iosapic_override_isa_irq()
 ia64_alloc_irq() -> ia64_alloc_vector()
 ia64_handle_irq() -> ia64_handle_vector() (<-? I'm not sure)
 register_percpu_irq() -> register_percpu_vector()

 pin -> rte_index
 pin -> pci_pin (where appropriate)
 max_pin -> max_redir or num_rte

Bjorn, I suppose there are conflicts with your idea of
name sanitization.
Comments are welcome.

Thanks,
-- 
KOCHI, Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


