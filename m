From: "Kenji Kaneshige" <kaneshige.kenji@jp.fujitsu.com>
Date: Mon, 17 May 2004 16:16:39 +0000
Subject: RE: [ACPI] Re: [PATCH] ACPI PCI IRQ routing rework
Message-Id: <200405171616.i4HGGht06511@incapgw2.fujitsu.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405170941.35673.bjorn.helgaas@hp.com>
In-Reply-To: <200405170941.35673.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Bjorn Helgaas' <bjorn.helgaas@hp.com>, "'Li, Shaohua'" <shaohua.li@intel.com>
Cc: acpi-devel@lists.sourceforge.net, "'Brown, Len'" <len.brown@intel.com>, 'David Mosberger' <davidm@hpl.hp.com>, 'Andi Kleen' <ak@suse.de>, "'Nakajima, Jun'" <jun.nakajima@intel.com>, linux-ia64@vger.kernel.org

I agree with you about CPEI, but how about PMI and INIT?
I think PMI and INIT need to be unmasked in somewhere.

Thanks,
Kenji Kaneshige

-----Original Message-----
From: linux-ia64-owner@vger.kernel.org
[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Bjorn Helgaas
Sent: Tuesday, May 18, 2004 12:42 AM
To: Li, Shaohua
Cc: acpi-devel@lists.sourceforge.net; Brown, Len; David Mosberger; Andi
Kleen; Nakajima, Jun; linux-ia64@vger.kernel.org
Subject: Re: [ACPI] Re: [PATCH] ACPI PCI IRQ routing rework

On Monday 17 May 2004 3:58 am, Li, Shaohua wrote:
> For the IOSAPIC, your patch mask interrupts in initialization, but
> should we mask platform interrupt?

I mask the interrupt in the IOSAPIC when programming the RTE.
This IOSAPIC programming happens before request_irq(), so I
think it makes sense to leave the RTE masked, because there's
nothing set up to do anything with an interrupt if it occurs.

If somebody's actually interested in the interrupt, there should
be a later request_irq() call, which will unmask the RTE via the
request_irq->setup_irq->startup path.

The only ia64 platform interrupt we do anything with is
ACPI_INTERRUPT_CPEI.  My usual test boxes don't support CPEI,
but from reading the code, iosapic_register_platform_intr()
programs the RTE (leaving it masked) when we parse the MADT.
Then ia64_mca_init() looks up the vector assigned for CPEI
and calls setup_irq() for it, which will unmask the RTE.

Maybe we could do a little rework to make ia64_mca_init() use
request_irq() (similar to how acpi_os_install_interrupt_handler()
works), but I think the current scheme should work.  Or do you
have evidence to the contrary?

Bjorn
-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


