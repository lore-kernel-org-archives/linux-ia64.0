From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 03 Jun 2005 21:09:04 +0000
Subject: Re: flush_icache_range
Message-Id: <17056.50928.777308.848952@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4236D7B5.8050408@bull.net>
In-Reply-To: <4236D7B5.8050408@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Looks fine to me.  The large number of shifts in the setup-code is a
bit unfortunate, but compared to the savings the larger stride
achieves on today's systems, this penalty is minor.  Still, if you
could find a sequence that's nicer to McKinley-type cores (with a
single shifter), that would be a plus.

The other slight concern I have is that if somebody calls
flush_icache_range() before cpu_init() has been called the first time,
it won't work.  We can probably live with it, but it would have been
nicer if there had been a clean way to default to stride=5 initially.

I think the patch is close enough that it should be put in the kernel.

	--david
