From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 12 May 2004 21:11:00 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <16546.37604.630631.37481@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 12 May 2004 12:03:28 -0700, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> Anyway, I'd appreciate any comments.  Maybe something like
  Jesse> this is ok for the mainline?  I haven't dealt with read_check
  Jesse> here, but I think the pseudocode would be something like
  Jesse> this:

So if multiple processes map the same I/O range then _all_ of them
will be terminated?  What if stuff gets remapped etc?  This all just
seems incredibly fragile to me.

	--david
