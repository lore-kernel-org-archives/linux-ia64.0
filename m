From: Christian.Hinkelbein@t-online.de (Christian Hinkelbein)
Date: Sat, 17 Jan 2004 18:47:10 +0000
Subject: Re: dma restriction on Itanium 2
Message-Id: <4009832E.9080702@ti.uni-mannheim.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1074304095.6384.13.camel@kbiswas-dt.s2iotech.com>
In-Reply-To: <1074304095.6384.13.camel@kbiswas-dt.s2iotech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Grant Grundler wrote:
> Yes. HPUX has a similar interface for DMA mapping but a completely
> different VM subsystem. Linux guarantees contiguous physical blocks
> for multi-page memory allocations. HPUX does not. The linux DMA
> subsystem uses that assumption.
you are talking about kernel-mode __get_free_pages and kmalloc,
and not user-mode malloc, arent you?

  christian

