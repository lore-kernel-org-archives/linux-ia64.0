From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 17 Oct 2002 19:38:34 +0000
Subject: Re: [Linux-ia64] BitKeeper tree for 2.4.x
Message-Id: <marc-linux-ia64-105590709805189@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805154@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805154@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> So what does "supported" by the chipset actually mean ? I've tested the 
> SCI cards in both BigSurs and ZX2000 and it works fine on IO memory 
> (roughly 330 MByte on both platforms).

One thing it means is that supported attributes have been considered
in the hardware design, tested (hopefully), and if they don't work, the
vendor should be interested.  If we use unsupported attributes, we're
exposing ourselves to the possibility of MCAs and data corruption.

> I can't really see why mapping main memory with WC (processor) should 
> affect the DMA performance of the AGP card.

If the AGP card reads main memory with non-coherent DMA, those
transactions don't need to be snooped by the processor, and may
not need to appear on the processor bus.

Bjorn


