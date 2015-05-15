From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 15 May 2015 20:48:36 +0000
Subject: Re: [RFC v1 11/11] genirq: Pass irq_data to helper function __irq_set_chip_handler_name_locked()
Message-Id: <alpine.DEB.2.11.1505152247280.4225@nanos>
List-Id: <linux-ia64.vger.kernel.org>
References: <1430709339-29083-1-git-send-email-jiang.liu@linux.intel.com> <1430709339-29083-12-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1430709339-29083-12-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Randy Dunlap <rdunlap@infradead.org>, Yinghai Lu <yinghai@kernel.org>, Borislav Petkov <bp@alien8.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, Linus Walleij <linus.walleij@linaro.org>, Alexandre Courbot <gnurou@gmail.com>, Michal Simek <michal.simek@xilinx.com>, =?ISO-8859-15?Q?S=F6ren_Brinkmann?= <soren.brinkmann@xilinx.com>, James Hogan <james.hogan@imgtec.com>, Jason Cooper <jason@lakedaemon.net>, Manuel Lauss <manuel.lauss@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-acpi@vger

On Mon, 4 May 2015, Jiang Liu wrote:
>  /* caller has locked the irq_desc and both params are valid */
>  static inline void
> -__irq_set_chip_handler_name_locked(unsigned int irq, struct irq_chip *chip,
> +__irq_set_chip_handler_name_locked(struct irq_data *data, struct irq_chip *chip,
>  				   irq_flow_handler_t handler, const char *name)
>  {
>  	struct irq_desc *desc;
>  
> -	desc = irq_to_desc(irq);
> -	irq_desc_get_irq_data(desc)->chip = chip;
> +	desc = irq_to_desc(data->irq);

We should have a irq_data_to_desc() helper and use that instead of
going through a full lookup again.

Thanks,

	tglx
