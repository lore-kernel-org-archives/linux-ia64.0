From: Rob Herring <robherring2@gmail.com>
Date: Fri, 06 Mar 2015 14:19:51 +0000
Subject: Re: [PATCH v5 16/29] powerpc/pci: Use pci_scan_host_bridge() for simplicity
Message-Id: <CAL_JsqJqpbTThfm2yctHr-gyySyxsJT3HS8rxm6oY+ZYVT5vvQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425634426-437-1-git-send-email-wangyijing@huawei.com> <1425634426-437-17-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1425634426-437-17-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yijing Wang <wangyijing@huawei.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-ia64@vger.kernel.org, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Russell King <linux@arm.linux.org.uk>, "x86@kernel.org" <x86@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Arnd Bergmann <arnd@arndb.de>, Marc Zyngier <marc.zyngier@arm.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-m68k@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yinghai@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Liviu Dudau <liviu@dudau.co.uk>, Tony Luck <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jiang Liu <jiang.liu@linux.intel.com>, linux-alpha@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>

On Fri, Mar 6, 2015 at 3:33 AM, Yijing Wang <wangyijing@huawei.com> wrote:
> Now we could use pci_scan_host_bridge() to scan
> pci buses, provide powerpc specific pci_host_bridge_ops.
>
> Suggested-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: linuxppc-dev@lists.ozlabs.org
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
> ---
>  arch/powerpc/include/asm/machdep.h       |    2 +-
>  arch/powerpc/kernel/pci-common.c         |   63 ++++++++++++++++++------------
>  arch/powerpc/platforms/pseries/pci.c     |    8 ++--
>  arch/powerpc/platforms/pseries/pseries.h |    2 +-
>  4 files changed, 44 insertions(+), 31 deletions(-)
>
> diff --git a/arch/powerpc/include/asm/machdep.h b/arch/powerpc/include/asm/machdep.h
> index 8e7f2a8..b811d12 100644
> --- a/arch/powerpc/include/asm/machdep.h
> +++ b/arch/powerpc/include/asm/machdep.h
> @@ -129,7 +129,7 @@ struct machdep_calls {
>         void            (*pcibios_fixup)(void);
>         int             (*pci_probe_mode)(struct pci_bus *);
>         void            (*pci_irq_fixup)(struct pci_dev *dev);
> -       int             (*pcibios_set_root_bus_speed)(struct pci_host_bridge
> +       void            (*pcibios_set_root_bus_speed)(struct pci_host_bridge
>                                 *bridge);

Shouldn't this be part of patch 15?

Rob
