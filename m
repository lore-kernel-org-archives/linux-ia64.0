From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 Jul 2004 01:57:25 +0000
Subject: Re: Next Revison of timer patches with split into nanosecond,
Message-Id: <16628.37637.516489.420207@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407131137160.3189@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407131137160.3189@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 13 Jul 2004 11:47:11 -0700 (PDT), Christoph Lameter <clameter@sgi.com> said:

  Christoph> +        do {
  Christoph> +                seq = read_seqbegin(&xtime_lock);
  Christoph> +                tv->tv_sec = xtime.tv_sec;
  Christoph> +                tv->tv_nsec = xtime.tv_nsec+time_interpolator_get_offset();
  Christoph> +        } while (unlikely(read_seqretry(&xtime_lock, seq)));
  Christoph> +
  Christoph> +        while (unlikely(tv->tv_nsec >= NSEC_PER_SEC)) {
  Christoph> +                tv->tv_nsec -= NSEC_PER_SEC;
  Christoph> +                ++tv->tv_sec;
  Christoph> +        }

It'd be better to use local variables to calculate the sec/nsec values
and then do a pair of stores at the end to update tv->tv_sec and
tv->tv_nsec.  The compiler most likely won't be able to use registers
otherwise (remember, the kernel gets compiled with
-fno-strict-aliasing!).

Some other comments:

 - thanks for breaking the patch up into 3 pieces; it might be useful
   to send the first one to lkml for discussion

 - there is still a shortage of blanks around operators (e.g.,
   assignment and arithmetic operators)

 - the fsys.S code depends on depends on the layout of the
   time_interpolator data-structure; that's OK, but it might be a good
   idea to add some safe-guards which ensure that the code fails to
   build if someone changes the layout of the structure

 - the fsys.S portion of the patch didn't apply for me; may be a
   problem on my end, given that it worked for Ken, but I'm out of
   time for today, so no other comments on that part (again, sorry)

Thanks,

	--david
