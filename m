From: <ameya.mitragotri@wipro.com>
Date: Sat, 14 Feb 2004 06:52:27 +0000
Subject: Nested interrupts in IA64 linux?
Message-Id: <CC7A2BA2F1CA9E43B2B62C4783B42C7BBDC332@blr-ec-msg05.wipro.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
A couple of queries on interrupts in IA64.

kernel Version: linux 2.6.2
Platform: Itanium-2 (2 CPU) 

1) Intel's manual  (Intel Itanium Architecture: Software Developers
Manual : Volume II) Chapter 3.4.3 (page 2:417) says that nested
interrupts are not supported. But the linux kernel source code 
(ia64_handle_irq) has some comment regarding handling nested 
interrupts. It's a little confusing here. Can anyone throw
some light on this? 

Does Linux support nested interrupts on IA64?

We tried to check our assumption (that it doesn't) by putting a 
mdelay in an interrupt context and found that no other interrupts are
received before the current one is over.

2) We tried to ack the current interrupt. The interrupt we were working
on was level triggered (USB keyboard). 
We did this:
a. Called ->end() of the interrupt descriptor. This will send an EOI to
the IOSAPIC. b. Called ia64_eoi() which sends eoi to the processor. c.
These steps should enable the next interrupts(??). d. We polled on ivr
to get the next interrupts in a loop as done in ia64_handle_irq
function). But this loop never returns a valid interrupt and continues
indefinitely.

The question is: 
are ->end() and ia64_eoi() (along with local_irq_enable()) sufficient to

ack an interrupt and accept the next one?

We are trying to do this because we want to dump (using LKCD) in a
keyboard 
interrupt context. This dump performs write on the SCSI device(Fusion
MPT), 
but we never seem to receive a SCSI interrupt indicating write
completion. 

This works perfectly fine if it is not from an interrupt context. Any
pointers will be really helpful.

Thanks and regards,
Ameya
