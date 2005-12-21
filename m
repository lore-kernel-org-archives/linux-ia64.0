From: Mark Maule <maule@sgi.com>
Date: Wed, 21 Dec 2005 19:03:49 +0000
Subject: Re: [PATCH 1/4] msi archetecture init hook
Message-Id: <20051221190349.GH9920@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051221184337.5003.85653.32527@attica.americas.sgi.com> <20051221184342.5003.74247.39285@attica.americas.sgi.com> <20051221185346.GC2361@parisc-linux.org>
In-Reply-To: <20051221185346.GC2361@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>

On Wed, Dec 21, 2005 at 11:53:46AM -0700, Matthew Wilcox wrote:
> On Wed, Dec 21, 2005 at 12:42:36PM -0600, Mark Maule wrote:
> > Index: msi/include/asm-sparc/msi.h
> > =================================> > --- msi.orig/include/asm-sparc/msi.h	2005-12-13 12:22:42.785246074 -0600
> > +++ msi/include/asm-sparc/msi.h	2005-12-13 16:09:49.194541334 -0600
> > @@ -28,4 +28,6 @@
> >  			      "i" (ASI_M_CTL), "r" (MSI_ASYNC_MODE) : "g3");
> >  }
> >  
> > +static inline int msi_arch_init(void)	{ return 0; }
> > +
> >  #endif /* !(_SPARC_MSI_H) */
> 
> As far as I can tell, you can't select MSI on Sparc, so this doesn't
> need to be here ...

Ok.  I'm a little confused on why we have asm-sparc/msi.h then.  Should I
yank it, or leave it for consistency and return -EINVAL so pci_enable_msi()
could fail somewhat gracefully on sparc ?

Mark
