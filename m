From: Brent Casavant <bcasavan@sgi.com>
Date: Wed, 17 Jan 2007 20:57:05 +0000
Subject: atomic_cmpxchg and 64-bit values
Message-Id: <20070117144850.U8085@pkunk.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I have what I hope is an easy to answer question.

The IA64 atomic_cmpxchg macro reads as follows (line continuation inserted):

	#define atomic_cmpxchg(v, old, new) \
		((int)cmpxchg(&((v)->counter), old, new))

Note that there's an integer cast on the return from cmpxchg().
This seems strange considering that the entire compxchg() code
path takes care to make sure that correctly-sized data types are
used throughout, including the return path.  The atomic_xchg()
macro

Is there some particular reason we need the cast to int on the
return path for atomic_cmpxchg()?  It looks to me as if this
macro would work equally well with an atomic_t or an atomic64_t.

Thanks,
Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
