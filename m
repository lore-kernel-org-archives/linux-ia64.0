From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 31 Jan 2008 05:04:17 +0000
Subject: Re: zx1 PCI DMA
Message-Id: <20080131050417.GB3836@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080130163128.GA26457@cse.unsw.EDU.AU>
In-Reply-To: <20080130163128.GA26457@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 31, 2008 at 03:31:28AM +1100, Matthew Chapman wrote:
> I'm trying to track down a PCI performance problem - part of my
> never-ending thesis troubles - and one thing I'm finding is that my HP
> zx1-based Itaniums are taking surprisingly long to satisfy PCI DMA
> reads.
> 
> On a 66Mhz PCI bus it seems to be taking about 60-75 bus cycles, i.e.
> ~1000ns, to initiate a read targetting a cache line that was previously
> owned by a processor.  Even cache lines that have recently been accessed
> by the PCI device, without being touched by a processor, seem to be
> taking of the order of 50 bus cycles.
> 
> This is a big surprise to me, since I know that zx1 performs really well
> CPU<->memory (order of 100ns).
> 
> Does anyone know what the achievable DMA latency should be, and what I
> can tune on the zx1 chipset or PCI card?

I just had a word with Grant Grundler.  He suggests looking at his OLS
paper at http://iou.parisc-linux.org/ols_2003/ "DMA Hints on
IA64/PARISC".

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
