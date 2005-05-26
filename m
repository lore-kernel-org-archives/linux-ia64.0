From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 26 May 2005 21:02:18 +0000
Subject: Re: [patch 0/4] ia64 SPARSEMEM
Message-Id: <1117141338.27082.26.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2005-05-26 at 16:54 -0400, Bob Picco wrote:
> luck wrote:	[Wed May 25 2005, 08:32:54PM EDT]
> > 
> > >+#ifdef CONFIG_SPARSEMEM
> > >+ /*
> > >+ * SECTION_SIZE_BITS            2^N: how big each section will be
> > >+ * MAX_PHYSADDR_BITS            2^N: how much physical address space we have
> > >+ * MAX_PHYSMEM_BITS             2^N: how much memory we can have in that space
> > >+ */
> > 
> > MAX_PHYSADDR_BITS is apparently never used ... what's the distinction
>
> Ah MAX_PHYSADDR_BITS appears not used by all arches ported to SPARSEMEM.  I 
> wonder if it's a remnant of NONLINEAR.  Dave, do you recall?

Yep, I think it's a remnant from nonlinear.  Something about how sparse
the memory will be.  We can compress the virtual address space if we're
careful.

-- Dave

