From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 14 Feb 2004 08:03:33 +0000
Subject: Re: Nested interrupts in IA64 linux?
Message-Id: <16429.54869.82093.174241@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CC7A2BA2F1CA9E43B2B62C4783B42C7BBDC332@blr-ec-msg05.wipro.com>
In-Reply-To: <CC7A2BA2F1CA9E43B2B62C4783B42C7BBDC332@blr-ec-msg05.wipro.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 14 Feb 2004 12:10:27 +0530, ameya.mitragotri@wipro.com said:

  Ameya> Does Linux support nested interrupts on IA64?

Yes.

  Ameya> We are trying to do this because we want to dump (using LKCD)
  Ameya> in a keyboard interrupt context. This dump performs write on
  Ameya> the SCSI device(Fusion MPT), but we never seem to receive a
  Ameya> SCSI interrupt indicating write completion.

Interrupts are divided into priority classes (16 vectors per class).
An interrupt at a vector that maps to a lower-or-equal class cannot
interrupt a pending interrupt.  The exact irq mapping will depend on
your machine (and may depend on the kernel), but here is an example
for a zx2000:

$ cat /proc/interrupts
           CPU0
 28:        132          LSAPIC  cpe_poll
 29:          0          LSAPIC  cmc_poll
 31:          0          LSAPIC  cmc_hndlr
 48:          0  IO-SAPIC-level  acpi
 49:      15566   IO-SAPIC-edge  serial
 60:         30  IO-SAPIC-level  sym53c8xx
 61:     445042  IO-SAPIC-level  sym53c8xx
 62:      76142  IO-SAPIC-level  ohci_hcd
 63:     170072  IO-SAPIC-level  ohci_hcd
 64:          0  IO-SAPIC-level  ehci_hcd
 65:         19  IO-SAPIC-level  ide1
 66:    2985681  IO-SAPIC-level  eth0
 67:          0  IO-SAPIC-level  FM801
232:          0          LSAPIC  mca_rdzv
238:          0          LSAPIC  perfmon
239:  121556726          LSAPIC  timer
240:          0          LSAPIC  mca_wkup
NMI:          0
ERR:          0

In this case, the SCSI controllers (sym53c8xx) are at vectors 60 and
61, which maps to priority class 3.  The USB vectors (62-64) map to
either priority class 3 or 4, so it's not surprising that you don't
get any SCSI interrupts while handing a (USB) keyboard interrupt.

If you want to force SCSI interrupts to come through, you'd have to
lower the task-priority-register (TPR).  You can see in
ia64_handle_irq() how this is done.  Of course, do this at our own
risk!

	--david
