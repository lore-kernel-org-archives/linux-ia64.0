From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 10 Dec 2003 15:44:19 +0000
Subject: Re: ia64 atomic_dec_and_lock() patch
Message-Id: <marc-linux-ia64-107107117511215@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107107082810707@msgid-missing>
In-Reply-To: <marc-linux-ia64-107107082810707@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> --- linux-2.6.0-test11.orig/arch/ia64/lib/dec_and_lock.c        1970-01-01
> 01:00:00.000000000 +0100
> +++ linux-2.6.0-test11/arch/ia64/lib/dec_and_lock.c     2003-12-09
> 11:31:23.000000000 +0100
> @@ -0,0 +1,42 @@
> +/*
> + * ia64 version of "atomic_dec_and_lock()" using
> + * the atomic "cmpxchg" instruction.
> + * This code is an adaptation of the x86 version
> + * of "atomic_dec_and_lock()".
> + */

You should probably add a copyright here and the license (i.e. GPLv2)

> +
> +#include <linux/spinlock.h>
> +#include <asm/atomic.h>
> +
> +#ifndef ATOMIC_DEC_AND_LOCK

Why this ifdef?

