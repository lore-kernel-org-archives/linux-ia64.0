From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 12 Aug 2004 15:21:23 +0000
Subject: Re: Altix I/O code reorganization
Message-Id: <20040812162123.A2145@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408042014.i74KE8fD141211@fsgi900.americas.sgi.com> <411AAABB.8070707@sgi.com> <20040812101507.C5988@infradead.org> <200408120747.02508.jbarnes@engr.sgi.com>
In-Reply-To: <200408120747.02508.jbarnes@engr.sgi.com>; from jbarnes@engr.sgi.com on Thu, Aug 12, 2004 at 07:47:02AM -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Patrick Gefre <pfg@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Aug 12, 2004 at 07:47:02AM -0700, Jesse Barnes wrote:
> Our platform does not currently support ACPI based PCI discovery and 
> configuration.  My claim is that this patchset gets us closer to being able 
> to implement it.  You aren't saying that any changes to the codebase should 
> be rejected until ACPI is 100% supported, are you?  That seems like a silly 
> stance to take since it precludes incremental improvements in the codebase.

Changes to the codebase are just fine.  Adding new interface to the prom
the duplicate the standard interface for that prupose on IA64 are not fine.

