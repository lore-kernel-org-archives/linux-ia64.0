From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 18 Jan 2007 18:13:24 +0000
Subject: Re: atomic_cmpxchg and 64-bit values
Message-Id: <Pine.LNX.4.64.0701181013110.11217@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070117144850.U8085@pkunk.americas.sgi.com>
In-Reply-To: <20070117144850.U8085@pkunk.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 17 Jan 2007, Andreas Schwab wrote:

> Brent Casavant <bcasavan@sgi.com> writes:
> 
> > Is there some particular reason we need the cast to int on the
> > return path for atomic_cmpxchg()?  It looks to me as if this
> > macro would work equally well with an atomic_t or an atomic64_t.
> 
> No, this is won't work, atomic_cmpxchg is strictly only defined for
> atomic_t.  See commit 4a6dae6d382e9edf3ff440b819e554ed706359bc.

Use cmpxchg instead of atomic_cmpxchg.

