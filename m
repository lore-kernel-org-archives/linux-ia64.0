From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 12 Aug 2004 09:15:07 +0000
Subject: Re: Altix I/O code reorganization
Message-Id: <20040812101507.C5988@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408042014.i74KE8fD141211@fsgi900.americas.sgi.com> <20040806141836.A9854@infradead.org> <411AAABB.8070707@sgi.com>
In-Reply-To: <411AAABB.8070707@sgi.com>; from pfg@sgi.com on Wed, Aug 11, 2004 at 06:24:43PM -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Gefre <pfg@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Aug 11, 2004 at 06:24:43PM -0500, Patrick Gefre wrote:
> This is a very BIG change.  However, the BIG change ends up with
> very little code in the kernel.  The reason is because, we have enhanced the
> functionalities in our Prom to actually configure and initialize all devices
> in the system instead of just the BaseIO devices.

Surely it can be spit out.  E.g. hwgraph removal is separate from your
SAL call stuff which is separate from dma mapping.

And,  let me repeat:

     There is absolutely _NO_ interest in adding yet another non-standard
     prom interface for PCI configuration.  IA64 has a standard ACPI-based
     interface that everyone but SGI implementent.  Please implement that one
     in your firmware.

> We do like our directory structures.  It provides very logical
> separation of code files.

You have more subdirectories than everything else in arch/ia64/ combined,
go figure. 

