From: Jack Steiner <steiner@sgi.com>
Date: Wed, 07 May 2008 12:51:49 +0000
Subject: Re: [PATCH 2/2] - IA64 machvec support for UV
Message-Id: <20080507125149.GA25711@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080506201857.GA4830@sgi.com>
In-Reply-To: <20080506201857.GA4830@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, May 06, 2008 at 10:44:28PM -0600, Alex Chiang wrote:
> * Jack Steiner <steiner@sgi.com>:
> >  
> > +config IA64_SGI_UV`
> > +	bool "SGI-UV`"
> > +	select NUMA
> > +	select ACPI_NUMA
> > +	select SWIOTLB
> > +	help
> > +	  Selecting this option will optimize the kernel for use on UV based
> > +	  systems, but the resulting kernel binary will not run on other
>                    ^^^
> 
> Should that be "and" instead of "but" ?
> 

Yes. Unfortunately, I cloned existing text that describes the SN2 option using
the same "but the resulting...".

If there are no other problems with this patch, let's apply it as posted.
I'll submit a cleanup patch to fix the text in both places.

Does that work???

--- jack
