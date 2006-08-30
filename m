From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 30 Aug 2006 22:48:05 +0000
Subject: Re: [RFC][PATCH 7/9] parisc generic PAGE_SIZE
Message-Id: <1156978085.31295.18.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060830221604.E7320C0F@localhost.localdomain>
	 <20060830221609.DA8E9016@localhost.localdomain>
	 <20060830224054.GG3926@athena.road.mcmartin.ca>
In-Reply-To: <20060830224054.GG3926@athena.road.mcmartin.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kyle McMartin <kyle@parisc-linux.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 2006-08-30 at 18:40 -0400, Kyle McMartin wrote:
> On Wed, Aug 30, 2006 at 03:16:09PM -0700, Dave Hansen wrote:
> > This is the parisc portion to convert it over to the generic PAGE_SIZE
> > framework.
> > 
> <snip>
> > Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
> 
> This looks pretty ok by me. I'll give it a test-build tonight.

That'd be great.  Thanks!

> > +config PARISC_LARGER_PAGE_SIZES
> > +	def_bool y
> >  	depends on PA8X00 && EXPERIMENTAL
> >  
> 
> This should default to 'n' as I do not believe we yet have working >4K
> pages yet.

This actually just defaults to enables the option to _appear_ in the
top-level Kconfig file.  The default from the top-level Kconfig file
should still be 4k for parisc.

-- Dave

