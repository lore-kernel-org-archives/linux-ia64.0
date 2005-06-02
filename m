From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 02 Jun 2005 22:23:33 +0000
Subject: Re: flush_icache_range
Message-Id: <17055.34533.385442.252286@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 02 Jun 2005 23:37:36 +0200, "Menyhart, Zoltan" <Zoltan.Menyhart@free.fr> said:

  Zoltan> I propose to round down "start_address" to be stride size aligned.

Sounds reasonable.

  >> As for setup.c: I'd get rid of LOG_2_I_CACHE_STRIDE_SIZE and just
  >> initialize log_2_i_cache_stride_size to 5 (there is no point in
  >> initializing it with a random & useless value).

  Zoltan> "log_2_i_cache_stride_size" is not initialized to any stride
  Zoltan> size, it calculates the min. value.  Should
  Zoltan> "pal_cache_config_info" fail, you need something useful to
  Zoltan> be able to boot up.

  Zoltan> I 'd rather keep "LOG_2_I_CACHE_STRIDE_SIZE", I like speaking names.
  Zoltan> Perhaps "LOG_2_DEFAULT_I_CACHE_STRIDE_SIZE" would be even better :-)

Sure.  The canonical way in Linux to say "log2" is "shift", so perhaps:

  DEFAULT_I_CACHE_STRIDE_SHIFT

?

  >> Also, I think you should do take the minimum of _all_ cache-levels,
  >> not just level 1 (yes, I also have a hard time imagining a system
  >> where the higher level has a smaller stride, but I don't think there
  >> is anything that prevents such a system).

  Zoltan> Well, things are getting complicated :-) I can add it...
  Zoltan> I've got a concern about the "unique_caches" returned by
  Zoltan> "pal_cache_summary()".  Let's assume that

  Zoltan> unique_caches - cache_levels = 2

  Zoltan> I could not find anything making sure that we've got in this
  Zoltan> case L1I and L2I, and not L1I and L3I (feeding through the
  Zoltan> unified L2). Yes, I know there is no such a CPU (at the
  Zoltan> moment) but the PAL spec. does not exclude it :-)

I don't think it matters whether you pick up the stride from an
i-cache or a unified cache.  As long as you take the minimum stride,
it will work correctly.

	--david
