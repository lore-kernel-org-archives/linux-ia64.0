From: Jerry Feldman <gerald.feldman@hp.com>
Date: Fri, 29 Apr 2005 19:39:12 +0000
Subject: Re: Incorrect return types for atomic64 functions in IA64 atomic.h
Message-Id: <200504291539.12924.gerald.feldman@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504291443.16040.gerald.feldman@hp.com>
In-Reply-To: <200504291443.16040.gerald.feldman@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 29 April 2005 3:10 pm, Andreas Schwab wrote:
> Jerry Feldman <gerald.feldman@hp.com> writes:
> > @@ -124,7 +124,7 @@ atomic_add_negative (int i, atomic_t *v)
> >         return atomic_add_return(i, v) < 0;
> >  }
> >
> > -static __inline__ int
> > +static __inline__ __s64
> >  atomic64_add_negative (__s64 i, atomic64_t *v)
> >  {
> >         return atomic64_add_return(i, v) < 0;
>
> This is wrong.  The return value is a boolean.
I agree. Should I resubmit the patch corrected, or will someone else do it.

-- 
Jerry Feldman <gerald.feldman@hp.com>
Partner Technology Access Center (contractor) (PTAC-MA)
Hewlett-Packard Co.
550 King Street LKG2a-X2
Littleton, Ma. 01460
 (978)506-5243
