From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 19 Jan 2002 20:10:01 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805888@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 19 Jan 2002 18:17:43 +0100 (MET), Erich Focht <focht@ess.nec.de> said:

  Erich> interrupts are disabled. Looking into the IA64 manuals
  Erich> I find that the text about psr.i emntions only disabling
  Erich> external interrupts, not the timer interrupt or internal
  Erich> interrupts coming from the local APIC (i.e. IPIs could also
  Erich> appear?).

  Erich> Does anybody know whether psr.i disables all interrupts or
  Erich> not? I tried setting the mmi bit on cr.tpr (mask maskable
  Erich> interrupts) in local_irq_disable() and local_irq_restore(),
  Erich> but I still see this kind of lockups.

  Erich> A quick fix for the scheduler is to return from the timer
  Erich> interrupt when the local runqueue is locked (same probably
  Erich> for IPIs) but ... isn't there a method to disable ALL
  Erich> interrupts?

psr.i *does* disable all interrupts, including NMI.  Device interrupts
are generally referred to as "external interrupts" in the ia64
manuals.  If you read the manual, you'll find there is no ambiguity
about this at all.  For example, see Table 5-8: External Interrupt
Control Registers; it lists ITV...

	--david

