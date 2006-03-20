From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 20 Mar 2006 19:44:41 +0000
Subject: Re: [PATCH 2.6.16-rc6-mm1] fix ia64 MSI build problems
Message-Id: <20060320194441.GK8980@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060320193638.GH31238@sgi.com>
In-Reply-To: <20060320193638.GH31238@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Maule <maule@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, gregkh@suse.de, akpm@osdl.org, j-nomura@ce.jp.nec.com

On Mon, Mar 20, 2006 at 01:36:38PM -0600, Mark Maule wrote:
> Index: maule/drivers/pci/Makefile
> =================================> --- maule.orig/drivers/pci/Makefile	2006-03-20 11:07:30.602099680 -0600
> +++ maule/drivers/pci/Makefile	2006-03-20 11:08:08.130604825 -0600
> @@ -26,7 +26,19 @@
>  obj-$(CONFIG_PPC64) += setup-bus.o
>  obj-$(CONFIG_MIPS) += setup-bus.o setup-irq.o
>  obj-$(CONFIG_X86_VISWS) += setup-irq.o
> -obj-$(CONFIG_PCI_MSI) += msi.o msi-apic.o
> +
> +ifdef CONFIG_PCI_MSI
> +obj-y += msi.o msi-apic.o
> +
> +ifdef CONFIG_IA64_GENERIC
> +obj-y += msi-altix.o
> +else
> +ifdef CONFIG_IA64_SGI_SN2
> +obj-y += msi-altix.o
> +endif
> +endif
> +
> +endif #CONFIG_PCI_MSI

The right way to do this kind of Makefile jiggery-pokery is:

msi-y := msi.o msi-apic.o
msi-$(CONFIG_IA64_GENERIC) += msi-altix.o
msi-$(CONFIG_IA64_SGI_SN2) += msi-altix.o
obj-$(CONFIG_PCI_MSI) += $(msi-y)

yay for declarative programming ;-)
