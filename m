From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 02 Jun 2005 18:28:20 +0000
Subject: Re: flush_icache_range
Message-Id: <17055.20420.963242.182611@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 02 Jun 2005 14:12:02 +0200, Zoltan Menyhart <Zoltan.Menyhart@bull.net> said:

  Zoltan> Here is my next try.

The changes to the assembly-file look mostly OK, except for the usual
white-space issues (trailing whitespace, introduction of new, useless
blank lines).

More importantly, it looks to me like there is an off-by-one bug:
ar.lc needs to be initialized to loop_count-1.  Which raises the
question: how well has this been tested?  Or am I missing something?

As for setup.c: I'd get rid of LOG_2_I_CACHE_STRIDE_SIZE and just
initialize log_2_i_cache_stride_size to 5 (there is no point in
initializing it with a random & useless value).

Also, I think you should do take the minimum of _all_ cache-levels,
not just level 1 (yes, I also have a hard time imagining a system
where the higher level has a smaller stride, but I don't think there
is anything that prevents such a system).

Thanks,

	--david
