From: Steffen Persvold <sp@scali.com>
Date: Thu, 17 Oct 2002 21:53:38 +0000
Subject: Re: [Linux-ia64] BitKeeper tree for 2.4.x
Message-Id: <marc-linux-ia64-105590709805190@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805154@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805154@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 17 Oct 2002, Bjorn Helgaas wrote:

> > So what does "supported" by the chipset actually mean ? I've tested the
> > SCI cards in both BigSurs and ZX2000 and it works fine on IO memory
> > (roughly 330 MByte on both platforms).
>
> One thing it means is that supported attributes have been considered
> in the hardware design, tested (hopefully), and if they don't work, the
> vendor should be interested.  If we use unsupported attributes, we're
> exposing ourselves to the possibility of MCAs and data corruption.
>

I agree, I actually have some bad experiences on IA32 platforms where
data corruption happened with CPU WC enabled (in MTRRs). Sorry for the
fuzz.

> > I can't really see why mapping main memory with WC (processor) should
> > affect the DMA performance of the AGP card.
>
> If the AGP card reads main memory with non-coherent DMA, those
> transactions don't need to be snooped by the processor, and may
> not need to appear on the processor bus.
>

Ok, and then I also see what you mean by "supported by the chipset"
because this must be managed by the memory controller and therefore it
must know what type of mappings are used by the processor. Kinda
complicated though... I thought the IO system didn't use coherence
protocols, and it was because of that we needed API functions such as
pci_dma_sync_single() and pci_dma_sync_sg() to manually ensure coherence..

Regards,
 --
  Steffen Persvold   | Scalable Linux Systems |   Try out the world's best
 mailto:sp@scali.com |  http://www.scali.com  | performing MPI implementation:
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6   |      - ScaMPI 1.13.8 -
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY   | >320MBytes/s and <4uS latency


