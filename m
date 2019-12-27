From: Kar Hin Ong <kar.hin.ong@ni.com>
Date: Fri, 27 Dec 2019 07:51:07 +0000
Subject: "oneshot" interrupt causes another interrupt to be fired erroneously in Intel Haswell system
Message-Id: <MN2PR04MB6255567B0B0060B0A8954605C32A0@MN2PR04MB6255.namprd04.prod.outlook.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-rt-users <linux-rt-users@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-x86_64@vger.kernel.org" <linux-x86_64@vger.kernel.org>, "platform-driver-x86@vger.kernel.org" <platform-driver-x86@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: Gratian Crisan <gratian.crisan@ni.com>

Hi,

I've an Intel Haswell system running Linux kernel v4.14 with preempt_rt patch. The system contain 2 IOAPICs: IOAPIC 1 is on the PCH where IOAPIC 2 is on the CPU.

I observed that whenever a PCI device is firing interrupt (INTx) to Pin 20 of IOAPIC 2 (GSI 44); the kernel will receives 2 interrupts: 
   1. Interrupt from Pin 20 of IOAPIC 2  -> Expected
   2. Interrupt from Pin 19 of IOAPIC 1  -> UNEXPECTED, erroneously triggered

The unexpected interrupt is unhandled eventually. When this scenario happen more than 99,000 times, kernel disables the interrupt line (Pin 19 of IOAPIC 1) and causing device that has requested it become malfunction.
I managed to also reproduced this issue on RHEL 8 and Ubuntu 19.04, 19.10 (without preempt_rt patch) after added "threadirqs" to the kernel command line.

After digging further, I noticed that the said issue is happened whenever an interrupt pin on IOAPIC 2 is masked:
 - Masking Pin 20 of IOAPIC 2 triggers Pin 19 of IOAPIC 1  
 - Masking Pin 22 of IOAPIC 2 triggers Pin 18 of IOAPIC 1  

I learnt that kernel will explicitly mask a specific interrupt pin before execute its handler, if the interrupt is configured as "oneshot" (i.e. threaded). Source: https://elixir.bootlin.com/linux/v4.14/source/kernel/irq/chip.c#L695  
This explained why it only happened on RTOS and Desktop Linux with "threadirqs" flag, because these configurations forces the interrupt handler to be threaded.

From Intel Xeon Processor E5/E7 v3 Product Family External Design Specification (EDS), Volume One: Architecture, section 13.1 (Legacy PCI Interrupt Handling), it mention:
"If the I/OxAPIC entry is masked (via the 'mask' bit in the corresponding Redirection Table Entry), then the corresponding PCI Express interrupt(s) is forwarded to the legacy PCH"

My interpretation is: when kernel receive a "oneshot" interrupt, it mask the line before start handling it. 
At this moment, if the interrupt line is still asserting, then the interrupt signal will be routed to the IOAPIC in PCH, and hence causing another interrupt to be fired erroneously and unhandled.  

Since the "route_to_pci" behaviour is documented in Intel spec, I presume it's a feature rather than a bug.
If this is a feature for intel processors, should the kernel irq handling routine be patched to handle it? 

Thanks.
Kar Hin Ong


