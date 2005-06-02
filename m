From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 02 Jun 2005 23:07:55 +0000
Subject: Re: flush_icache_range
Message-Id: <17055.37195.837203.851634@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 03 Jun 2005 00:55:42 +0200, "Menyhart, Zoltan" <Zoltan.Menyhart@free.fr> said:

  Zoltan> I mean:

  Zoltan> - if the cache of a given level is split, then we need to
  Zoltan> take the stride size of the i-cache:
  Zoltan> pal_cache_config_info(level, /* cache_type = */ 1,...)

  Zoltan> - if the cache of a given level is unified, then we need to
  Zoltan> take the stride size of the unified/data cache:
  Zoltan> pal_cache_config_info(level, /* cache_type = */ 2,...)

  Zoltan> In my example I know only that some (but not all) the levels
  Zoltan> are split.  Guessing the existence of a split cache by not
  Zoltan> obtaining an "Invalid argument" error form
  Zoltan> "pal_cache_config_info()" is a bit weak method...

Ah, I misremembered: I thought a cache_type value of 1 means
"instruction-cache or unified", but no, it means _only_
instruction-cache.  So the safe sequence seems to be:

   pal_cache_config_info(level, 2, &info)
   if (!info.pcci_unified)
	pal_cache_config_info(level, 1, &info)

While I omitted the failure checks, of course, this doesn't look too
bad.

	--david
