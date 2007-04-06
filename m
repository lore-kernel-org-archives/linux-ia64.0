From: Mike Habeck <habeck@sgi.com>
Date: Fri, 06 Apr 2007 18:53:59 +0000
Subject: Re: [PATCH] SGI Altix : fix pcibr_dmamap_ate32() bug
Message-Id: <46169747.BC2CB260@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070406170439.24071.57637.75833@attica.americas.sgi.com>
In-Reply-To: <20070406170439.24071.57637.75833@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Luck, Tony" wrote:
> 
> Can you explain this part of the patch?
> 
> -#define PCI32_ATE_CO                    (0x1 << 1)
> -#define PCI32_ATE_PREC                  (0x1 << 2)
> +#define PCI32_ATE_CO                    (0x1 << 1)     /* PIC ASIC ONLY */
> +#define PCI32_ATE_PIO                   (0x1 << 1)     /* TIOCP ASIC ONLY */
> 
> Why is PCI32_ATE_PIO now the same value as PCI_ATE_CO?

The ATE (Address Translation Entry for 32bit PCI mappings) Attribute 
bits are different for our PIC Bridge ASIC and our TIOCP Bridge ASIC.  
On our PIC Bridge ASIC bit#1 is the `Coherent Translation' attribute, 
but on our TIOCP Bridge ASIC bit#1 is the `PIO' attribute

-mike
