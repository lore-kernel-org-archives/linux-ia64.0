From: Grant Grundler <iod00d@hp.com>
Date: Sat, 17 Jan 2004 03:58:54 +0000
Subject: Re: dma restriction on Itanium 2
Message-Id: <20040117035854.GH18103@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1074304095.6384.13.camel@kbiswas-dt.s2iotech.com>
In-Reply-To: <1074304095.6384.13.camel@kbiswas-dt.s2iotech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kallol,
please continue to include the linux-ia64 list in your replies.

On Fri, Jan 16, 2004 at 06:35:53PM -0800, Kallol Biswas wrote:
> Yes, I was talking about under HP-UX.
> 
> Just to verify, inability to do DMA over page boundary on PA-RISC
> running HP-UX was a software limitation or hardware? You are saying
> it was a hp-ux(software) limitation, right?

Yes. HPUX has a similar interface for DMA mapping but a completely
different VM subsystem. Linux guarantees contiguous physical blocks
for multi-page memory allocations. HPUX does not. The linux DMA
subsystem uses that assumption.

I'm hoping someone who is better at decoding MCA data can
take a quick look at the data you posted earlier. If no one
else does by next week, I'll work on it then.

grant
