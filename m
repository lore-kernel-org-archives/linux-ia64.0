From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Date: Tue, 30 Oct 2007 19:09:02 +0000
Subject: RE: [PATCH] ia64: Fix incorrect return value from ia64_setup_msi_irq()
Message-Id: <78C9135A3D2ECE4B8162EBDCE82CAD7702765478@nekter>
List-Id: <linux-ia64.vger.kernel.org>
References: <4726D6DD.9090300@jp.fujitsu.com>
In-Reply-To: <4726D6DD.9090300@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch fixes a problem we encountered enabling msi-x on the ia64
platform, on 2.6.24-rc1. Please accept this patch as without it,
pci_enable_msix() will always fail on ia64 platforms.

> hpcpc103:~# ethtool -i eth7
> driver: Neterion
> version: 2.0.26.5
> firmware-version:
> bus-info: 0000:0f:01.0
> hpcpc103:~# ifconfig eth7 192.168.7.103
> eth7: Enabling MSIX failed
> eth7: MSI-X requested but failed to enable
> eth7: Link Up
> ADDRCONF(NETDEV_UP): eth7: link is not ready hpcpc103:~# 
> ADDRCONF(NETDEV_CHANGE): eth7: link becomes ready

Thanks,
Ram
> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org [mailto:linux-ia64-
> owner@vger.kernel.org] On Behalf Of Kenji Kaneshige
> Sent: Monday, October 29, 2007 11:02 PM
> To: linux-ia64@vger.kernel.org; Luck, Tony
> Subject: [PATCH] ia64: Fix incorrect return value from
> ia64_setup_msi_irq()
> 
> Hi,
> 
> Here is a patch to fix the problem that pci_enable_msi() always fails
> on ia64 platform.
> 
> Thanks,
> Kenji Kaneshige
> ---
> 
> Fix the problem that pci_enable_msi() fails on ia64 platform. The
cause of
> this problem is incorrect return value of ia64_setup_msi_irq(). It
must
> return 0 on success, instead of irq number.
> 
> Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
> 
> ---
>  arch/ia64/kernel/msi_ia64.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6.24-rc1/arch/ia64/kernel/msi_ia64.c
> =================================> --- linux-2.6.24-rc1.orig/arch/ia64/kernel/msi_ia64.c
> +++ linux-2.6.24-rc1/arch/ia64/kernel/msi_ia64.c
> @@ -109,7 +109,7 @@ int ia64_setup_msi_irq(struct pci_dev *p
>  	write_msi_msg(irq, &msg);
>  	set_irq_chip_and_handler(irq, &ia64_msi_chip, handle_edge_irq);
> 
> -	return irq;
> +	return 0;
>  }
> 
>  void ia64_teardown_msi_irq(unsigned int irq)
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64"
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
