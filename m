From: Kallol Biswas <kallol.biswas@s2io.com>
Date: Sat, 17 Jan 2004 01:48:15 +0000
Subject: dma restriction on Itanium 2
Message-Id: <1074304095.6384.13.camel@kbiswas-dt.s2iotech.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We have been seeing a problem on itanium 2 running linux 2.4.21-4.EL 
with our 10GB ethernet card.
The error is PCI related. On PARISC systems the DMA address could not
span page boundary due to hardware limitation, do we have the same
limitation on Itanium 2 systems also? If the transmit or receive
descriptors take more than a page then they should be aligned such a way
that DMA does not happen over a page right?



