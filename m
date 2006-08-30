From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 30 Aug 2006 14:56:41 +0000
Subject: Re: [RFC][PATCH 10/10] convert the "easy" architectures to generic
Message-Id: <1156949801.12898.5.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060829201934.47E63D1F@localhost.localdomain>
	 <20060829201941.38D6254C@localhost.localdomain>
	 <20060830100518.GA10629@localhost.internal.ocgnet.org>
In-Reply-To: <20060830100518.GA10629@localhost.internal.ocgnet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Mundt <lethal@linux-sh.org>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, rdunlap@xenotime.net

On Wed, 2006-08-30 at 05:05 -0500, Paul Mundt wrote:
> 
> > -/* PAGE_SHIFT determines the page size */
> > -#define PAGE_SHIFT   12
> > -#define PAGE_SIZE    (1UL << PAGE_SHIFT)
> > -#define PAGE_MASK    (~(PAGE_SIZE-1))
> > -#define PTE_MASK     PAGE_MASK
> > +#include <asm-generic/page.h>
> >  
> Overzealous deletion? Please leave PTE_MASK there, we use it for
> _PAGE_CHG_MASK in pgtable.h.

Yes.  I'll fix that up.

-- Dave

