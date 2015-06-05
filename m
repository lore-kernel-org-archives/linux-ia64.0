From: Ralf Baechle <ralf@linux-mips.org>
Date: Fri, 05 Jun 2015 08:48:03 +0000
Subject: Re: [Patch v3 35/36] genirq: Pass irq_data to helper function __irq_set_chip_handler_name_locked()
Message-Id: <20150605084803.GY26432@linux-mips.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1433145945-789-1-git-send-email-jiang.liu@linux.intel.com>
 <1433145945-789-36-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1433145945-789-36-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Bjorn Helgaas <bhelgaas@google.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Randy Dunlap <rdunlap@infradead.org>, Yinghai Lu <yinghai@kernel.org>, Borislav Petkov <bp@alien8.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Linus Walleij <linus.walleij@linaro.org>, Alexandre Courbot <gnurou@gmail.com>, Michal Simek <michal.simek@xilinx.com>, =?iso-8859-1?Q?S=F6ren?= Brinkmann <soren.brinkmann@xilinx.com>, James Hogan <james.hogan@imgtec.com>, Jason Cooper <jason@lakedaemon.net>, Manuel Lauss <manuel.lauss@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Mon, Jun 01, 2015 at 04:05:44PM +0800, Jiang Liu wrote:

For arch/mips/alchemy/common/irq.c:

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
