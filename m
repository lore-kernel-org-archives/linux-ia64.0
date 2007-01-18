From: Brent Casavant <bcasavan@sgi.com>
Date: Thu, 18 Jan 2007 23:43:55 +0000
Subject: Re: atomic_cmpxchg and 64-bit values
Message-Id: <20070118173919.B15966@pkunk.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070117144850.U8085@pkunk.americas.sgi.com>
In-Reply-To: <20070117144850.U8085@pkunk.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 18 Jan 2007, Christoph Lameter wrote:

> On Wed, 17 Jan 2007, Andreas Schwab wrote:
> 
> > Brent Casavant <bcasavan@sgi.com> writes:
> > 
> > > Is there some particular reason we need the cast to int on the
> > > return path for atomic_cmpxchg()?  It looks to me as if this
> > > macro would work equally well with an atomic_t or an atomic64_t.
> > 
> > No, this is won't work, atomic_cmpxchg is strictly only defined for
> > atomic_t.  See commit 4a6dae6d382e9edf3ff440b819e554ed706359bc.
> 
> Use cmpxchg instead of atomic_cmpxchg.

There was a better solution anyway.  I was trying to stash a pointer
in the atomic as an ownership token, and that of course was fraught with
peril as you need an atomic_t or atomic64_t, depending on platform.

In the end I decided to use a non-pointer unique token rather than
deal with the 32/64-bit hassle, which also sidestepped the whole
question about the (int) cast.

Thanks you both for the responses though.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
