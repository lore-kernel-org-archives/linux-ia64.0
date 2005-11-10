From: Robin Holt <holt@sgi.com>
Date: Thu, 10 Nov 2005 09:13:14 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051110091314.GA7928@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> For example, if you have:
> 
> 	128 GB per SSI 
> 	16 SSIs connected via NUMALINK
> 
> a task running within an SSI can access all 2TB of memory (excluding memory
> used by the kernel)

And here to, access may not mean exactly what you expect.  Some accesses
are simple uncached accesses.  Some are cached accesses for the owning
SSI uncached accesses for the remote side (write coalesced).  Some are
DMA reads from the remote side to cachable local side.  When Jack says
access, he truly means it in a very broad sense.

Thanks,
Robin
