From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 06 Jan 2005 21:19:51 +0000
Subject: Re: [PATCH] cleanup swiotlb.c a bit
Message-Id: <16861.43895.318193.345787@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060945.12364.jbarnes@engr.sgi.com>
In-Reply-To: <200501060945.12364.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 6 Jan 2005 12:07:57 -0800, Jesse Barnes <jbarnes@engr.sgi.com> said:
  Jesse> Really?  In my experience the core files are generally pretty
  Jesse> good (every now and then a long line creeps in, but there
  Jesse> aren't that many that I can see).  Any big offenders that
  Jesse> really bug you?

It certainly has improved recent, but still there enough declarations
etc that are too wide for 80 cols.

  Jesse> Well if you don't like them either (that makes none that I
  Jesse> know of), shouldn't we at least fixup the ia64 bits,
  Jesse> regardless of what happens with the core kernel files?

I'm not sure that's much of an improvement, but if you think
otherwise, go for it.

	--david
