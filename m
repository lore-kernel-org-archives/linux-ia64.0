From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 16 Dec 2004 18:56:12 +0000
Subject: Re: [PATCH] add legacy I/O port & memory APIs to /proc/bus/pci
Message-Id: <200412161056.13019.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412160850.20223.jbarnes@engr.sgi.com> <16833.55270.601527.754270@napali.hpl.hp.com>
In-Reply-To: <16833.55270.601527.754270@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, willy@debian.org

On Thursday, December 16, 2004 10:45 am, David Mosberger wrote:
> >>>>> On Thu, 16 Dec 2004 08:50:19 -0800, Jesse Barnes
> >>>>> <jbarnes@engr.sgi.com> said:
>
>   Jesse> +int ia64_pci_legacy_read(struct pci_dev *dev, u16 port, u32 *val,
> u8 size) Jesse> +{
>   Jesse> + int ret = 0;
>   Jesse>         :
>   Jesse> + case 1:
>   Jesse> +  addr = (unsigned long *)paddr;
>   Jesse> +  *val = (u8)(*(volatile u8 *)(addr));
>   Jesse> +  break;
>   Jesse> + case 2:
>   Jesse> +  addr = (unsigned long *)paddr;
>   Jesse> +  *val = (u16)(*(volatile u16 *)(addr));
>   Jesse> +  break;
>   Jesse>          :
>   Jesse> +}
>
>   Jesse> +int ia64_pci_legacy_write(struct pci_dev *dev, u16 port, u32 val,
> u8 size) Jesse> +{
>   Jesse> + switch (size) {
>   Jesse> + case 1:
>   Jesse> +  addr = (unsigned long *)paddr;
>   Jesse> +  *(volatile u8 *)(addr) = (u8)(val);
>   Jesse> +  break;
>   Jesse> + case 2:
>   Jesse> +  addr = (unsigned long *)paddr;
>   Jesse> +  *(volatile u16 *)(addr) = (u16)(val);
>   Jesse> +  break;
>   Jesse>           :
>   Jesse> + }
>
> No offense, but what's up with this castamania?

Leftovers from other code.  I don't actually use this stuff on sn2, someone 
with a DIG test box will have to verify it (willy pointed out that I should 
probably just be using the appropriate inX our outX routine here instead, 
which makes sense).

Jesse
