From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 12 Aug 2004 14:47:02 +0000
Subject: Re: Altix I/O code reorganization
Message-Id: <200408120747.02508.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408042014.i74KE8fD141211@fsgi900.americas.sgi.com> <411AAABB.8070707@sgi.com> <20040812101507.C5988@infradead.org>
In-Reply-To: <20040812101507.C5988@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: Patrick Gefre <pfg@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thursday, August 12, 2004 2:15 am, Christoph Hellwig wrote:
> And,  let me repeat:
>
>      There is absolutely _NO_ interest in adding yet another non-standard
>      prom interface for PCI configuration.  IA64 has a standard ACPI-based
>      interface that everyone but SGI implementent.  Please implement that
> one in your firmware.

Our platform does not currently support ACPI based PCI discovery and 
configuration.  My claim is that this patchset gets us closer to being able 
to implement it.  You aren't saying that any changes to the codebase should 
be rejected until ACPI is 100% supported, are you?  That seems like a silly 
stance to take since it precludes incremental improvements in the codebase.

IOW, assuming the patchset meets with general approval in other ways, you 
wouldn't oppose its inclusion just because it doesn't go far enough, would 
you?

Thanks,
Jesse
