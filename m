From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 04 May 2004 23:31:47 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <16536.10211.963767.500306@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 May 2004 16:17:30 -0700, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> That's nice (that's why I wanted a pointer to a spec--I can
  Jesse> hand it to our hw guys who have been asking for it).

I'm not sure you'll find an explicit statement to that effect.  In my
opinion, it's implied because the x86 IN/OUT instructions do not (and
should not) cause MCAs.

	--david
