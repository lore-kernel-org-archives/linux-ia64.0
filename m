From: "Tian, Kevin" <kevin.tian@intel.com>
Date: Fri, 22 Oct 2004 01:22:48 +0000
Subject: RE: request_irq() and setup_irq()
Message-Id: <571ACEFD467F7749BC50E0A98C17CDD80528CF08@pdsmsx403>
List-Id: <linux-ia64.vger.kernel.org>
References: <4177D1A4.1040009@hob.de>
In-Reply-To: <4177D1A4.1040009@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>-----Original Message-----
>From: linux-ia64-owner@vger.kernel.org
[mailto:linux-ia64-owner@vger.kernel.org]
>On Behalf Of Christian Hildner
>Sent: Thursday, October 21, 2004 11:12 PM
>Hi,
>
>looking through the sources of 2.4.21 there come up one question. If a
>device wants to register its interrupt it may call request_irq() that
>then calls setup_irq(). Now since SA_PERCPU_IRQ is not set by the
device
>setup_irq() does not initialize desc->handler. Can that be fixed by
>adding SA_PERCPU_IRQ to irqflags in request_irq() or does that
introduce
>problems at another place?
>
>Christian

ACPI can provide MADT table for lsapic and iosapic info in local system.
From that table, linux will configure interrupt controller info for each
interrupt line when bootup. You can look at iosapic_init(), which
constructs per-line info related to iosapic. Say, by trigger mode of
specific line, register_intr() will decide whether irq_type_iosapic_edge
or irq_type_iosapic_level should be used. 

Thanks,
Kevin
