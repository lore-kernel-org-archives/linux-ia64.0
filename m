From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 16 Dec 2004 18:45:58 +0000
Subject: Re: [PATCH] add legacy I/O port & memory APIs to /proc/bus/pci
Message-Id: <16833.55270.601527.754270@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412160850.20223.jbarnes@engr.sgi.com>
In-Reply-To: <200412160850.20223.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, willy@debian.org

>>>>> On Thu, 16 Dec 2004 08:50:19 -0800, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> +int ia64_pci_legacy_read(struct pci_dev *dev, u16 port, u32 *val, u8 size)
  Jesse> +{
  Jesse> +	int ret = 0;
  Jesse>         :
  Jesse> +	case 1:
  Jesse> +		addr = (unsigned long *)paddr;
  Jesse> +		*val = (u8)(*(volatile u8 *)(addr));
  Jesse> +		break;
  Jesse> +	case 2:
  Jesse> +		addr = (unsigned long *)paddr;
  Jesse> +		*val = (u16)(*(volatile u16 *)(addr));
  Jesse> +		break;
  Jesse>          :
  Jesse> +}

  Jesse> +int ia64_pci_legacy_write(struct pci_dev *dev, u16 port, u32 val, u8 size)
  Jesse> +{
  Jesse> +	switch (size) {
  Jesse> +	case 1:
  Jesse> +		addr = (unsigned long *)paddr;
  Jesse> +		*(volatile u8 *)(addr) = (u8)(val);
  Jesse> +		break;
  Jesse> +	case 2:
  Jesse> +		addr = (unsigned long *)paddr;
  Jesse> +		*(volatile u16 *)(addr) = (u16)(val);
  Jesse> +		break;
  Jesse>           :
  Jesse> +	}

No offense, but what's up with this castamania?

	--david
