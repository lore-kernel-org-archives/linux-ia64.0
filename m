From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 12 May 2004 21:54:41 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <16546.40225.607307.380778@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 12 May 2004 14:44:22 -0700, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> On Wednesday, May 12, 2004 2:35 pm, David Mosberger wrote:
  >> It definitely falls in the experimental category.  That isn't bad but
  >> I don't think it's mainline material.  Certainly not for 2.6.

  Jesse> What would you like to see before it hits the mainline?  The
  Jesse> read_check support implemented?  For better or worse, that
  Jesse> requires a lot of buy in on lkml.  Just looking for other
  Jesse> suggestions...

I just don't see a lot of demand for this kind of feature at this
point, so why bloat the kernel?  Plus the solution so far seems rather
incomplete and fragile.  I suggest to play with this in a separate
tree and if users start to really like the patch and can't live
without it, well, I'm sure I'll hear about it.

	--david
