From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 04 May 2004 22:51:38 +0000
Subject: Re: [RFC] I/O MCA recovery
Message-Id: <16536.7802.708720.962992@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405040954.09524.jbarnes@engr.sgi.com>
In-Reply-To: <200405040954.09524.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 May 2004 15:36:13 -0700, Jesse Barnes <jbarnes@engr.sgi.com> said:

  >>  User-level accesses are mapped via the MMU so you could always
  >> intercept the page-faults.

  Jesse> Wouldn't that mean that on every I/O access we'd have to page
  Jesse> fault, do the I/O, and then invalidate the mapping?  That
  Jesse> seems like a lot of overhead.

Yes.  I doubt it would be an issue for inX/outX emulation in the int10
module.

  Jesse> Also, with this scheme, we could potentially recover from
  Jesse> regular read/writes too.

  >>  _If_ there is an infrastructure what you can hook into, fine.
  >> But I'm highly suspicious of using broken platforms as a
  >> justification for new infrastructure.

  Jesse> Are you describing ia64 as a broken platform here?

Hardly.

  Jesse> The problem I'm trying to solve isn't sn2 specific (though
  Jesse> part of the X stuff I have to do will be driven by sn2
  Jesse> requirements)

I was talking about hard-failure of inX/outX.  If SN2 does that, it's
broken and I'm not terribly sympathetic (but see below).

  Jesse> it's a generic way to deal with hard fails on PIO reads,
  Jesse> which afaik, affects all ia64 platforms.  Correct me if I'm
  Jesse> wrong here...

Let me try to say it differently: inX/outX must soft-fail.  How you
achieve that on SN2, I don't really care.  If, for other reasons,
there happens to be an infrastructure you can hook into to facility
implementation of soft-fail inX/outX on SN2, that's certainly fine by
me.  But don't try to use inX/outX soft-fail as a reason to justify
the infrastructure.  Better?

	--david
