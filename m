From: Mario Smarduch <cms063@email.mot.com>
Date: Wed, 17 Mar 2004 16:57:38 +0000
Subject: Re: UCE and NUMA
Message-Id: <40588382.566B40EA@email.mot.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40576628.927DEB35@email.mot.com>
In-Reply-To: <40576628.927DEB35@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:

> >>>>> On Tue, 16 Mar 2004 14:40:08 -0600, Mario Smarduch <cms063@email.mot.com> said:
>
>   Mario> Hi, we're currently evaluating a NUMA system (8-way). We're
>   Mario> wondering for hot contention spots does the 2.4 or 2.6 kernel
>   Mario> make use of IA64 UCE Memory attribute (fetchadd)?  Has anyone
>   Mario> been able to catpure relative performance differences (WB
>   Mario> vs. UCE) for any benchmark ?
>
> Note that UCE is both CPU model- and platform-specific.  Even then,
> only "fetchadd" is supported (not cmpxchg, which is what's normally
> used for spinlocks).  Furthermore, you have to be really careful to
> avoid attribute-aliasing.
>
> As long as those constraints are met, I suppose it would be OK to use
> UCE.
>
> However, is UCE really beneficial for spinlocks?  I thought it's
> primary use would be for atomic operations (such as atomic inc).
>
>         --david

 I suppose you could use fetchadd
to build some crude lockout mechanism, but probably
more useful is shared kernel data that regularly
may get updated by all CPUs (i.e. dec/inc atomically ).
That may save on WB   cache-coherency waste of bandwidth for
contentious spots.

But I agree practically it would be pretty difficult to (i) first
figure out what is very contentious (ii) and locate all your locks/data
into those UCE pages. So in short UCE is not used in any
kernel version?

- Mario

