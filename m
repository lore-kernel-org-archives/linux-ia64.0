From: Grant Grundler <iod00d@hp.com>
Date: Mon, 19 Jan 2004 06:14:38 +0000
Subject: Re: dma restriction on Itanium 2
Message-Id: <20040119061438.GA1437@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1074304095.6384.13.camel@kbiswas-dt.s2iotech.com>
In-Reply-To: <1074304095.6384.13.camel@kbiswas-dt.s2iotech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Jan 17, 2004 at 07:47:10PM +0100, Christian Hinkelbein wrote:
> Grant Grundler wrote:
> >Yes. HPUX has a similar interface for DMA mapping but a completely
> >different VM subsystem. Linux guarantees contiguous physical blocks
> >for multi-page memory allocations. HPUX does not. The linux DMA
> >subsystem uses that assumption.
> you are talking about kernel-mode __get_free_pages and kmalloc,
> and not user-mode malloc, arent you?

yes - kmalloc.
Sorry - I assumed it was clear this whole discussion
was about kernel internals.

grant
