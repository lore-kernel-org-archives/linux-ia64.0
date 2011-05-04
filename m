From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 04 May 2011 15:04:04 +0000
Subject: Re: [PATCH] atomic: add *_dec_not_zero
Message-Id: <1304521444.2810.23.camel@mulgrave.site>
List-Id: <linux-ia64.vger.kernel.org>
References: <1304458235-28473-1-git-send-email-sven@narfation.org>
	 <BANLkTiminpyJ_opxhqG0E0gBOrF490b+tQ@mail.gmail.com>
In-Reply-To: <BANLkTiminpyJ_opxhqG0E0gBOrF490b+tQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Frysinger <vapier.adi@gmail.com>
Cc: Sven Eckelmann <sven@narfation.org>, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, Chris Metcalf <cmetcalf@tilera.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, uclinux-dist-devel@blackfin.uclinux.org, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m32r@ml.linux-m32r.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org

On Wed, 2011-05-04 at 00:44 -0400, Mike Frysinger wrote:
> On Tue, May 3, 2011 at 17:30, Sven Eckelmann wrote:
> > Introduce an *_dec_not_zero operation.  Make this a special case of
> > *_add_unless because batman-adv uses atomic_dec_not_zero in different
> > places like re-broadcast queue or aggregation queue management. There
> > are other non-final patches which may also want to use this macro.
> >
> > Cc: uclinux-dist-devel@blackfin.uclinux.org
> >
> > --- a/arch/blackfin/include/asm/atomic.h
> > +++ b/arch/blackfin/include/asm/atomic.h
> > @@ -103,6 +103,7 @@ static inline int atomic_test_mask(int mask, atomic_t *v)
> >        c != (u);                                               \
> >  })
> >  #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
> > +#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
> >
> >  /*
> >  * atomic_inc_and_test - increment and test
> 
> no opinion on the actual idea, but for the Blackfin pieces:
> Acked-by: Mike Frysinger <vapier@gentoo.org>

This goes for parisc as well.

Acked-by: James Bottomley <James.Bottomley@HansenPartnership.com>

James


