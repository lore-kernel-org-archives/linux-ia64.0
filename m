From: jerome.marchand@ext.bull.net
Date: Wed, 10 Dec 2003 16:06:53 +0000
Subject: Re: ia64 atomic_dec_and_lock() patch
Message-Id: <marc-linux-ia64-107107266313648@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107107082810707@msgid-missing>
In-Reply-To: <marc-linux-ia64-107107082810707@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Wed, 10 Dec 2003, Christoph Hellwig wrote:

> You should probably add a copyright here and the license (i.e. GPLv2)

Right.

> > +
> > +#include <linux/spinlock.h>
> > +#include <asm/atomic.h>
> > +
> > +#ifndef ATOMIC_DEC_AND_LOCK
>
> Why this ifdef?

Oops! It is a polution of the lockmeter patch. This ifdef should be in the
ia64-lockmeter patch.


