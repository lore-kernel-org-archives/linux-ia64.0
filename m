From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 May 2004 01:17:14 +0000
Subject: Re: [PATCH] early console registration
Message-Id: <16556.1818.94844.895240@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405141425.59867.jbarnes@engr.sgi.com>
In-Reply-To: <200405141425.59867.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 14 May 2004 14:25:59 -0700, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> Is this reasonable?  I've tested it on a couple of machines
  Jesse> here and it works well.  It's really useful for debugging
  Jesse> setup_arch problems.

I don't like the #ifdef's very much, but I suppose I can live with
them in this case.  IIRC, Bjorn also has been working on some
early-printk changes so I'd be interested in his opinion.

	--david
