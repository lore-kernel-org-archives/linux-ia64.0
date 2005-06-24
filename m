From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 24 Jun 2005 21:53:47 +0000
Subject: Re: [patch] Memory Error Handling Improvement
Message-Id: <17084.33003.866233.619727@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 24 Jun 2005 16:36:02 -0500 (CDT), Russ Anderson <rja@sgi.com> said:

  Russ> David Mosberger wrote:

  >> >> Fine, but what about stores?

  Tony> Stores have too many extra levels of buffering to have much
  Tony> hope.  But just because we can't help the store case doesn't
  Tony> mean that we shouldn't do something about the load case.

  >> Fine, but what about my suggestion of just presuming that the access
  >> came for user-level unless you can prove otherwise?

  Russ> The key question is how to prove otherwise.

  Russ> Ironicly, my concern was this patch would be seen as too
  Russ> aggressive and therefore risky.  So the patch is limited to
  Russ> the interrupt case, which seemed to be a heavy hitter in
  Russ> testing.  I hadn't expected pushback for not being aggressive
  Russ> enough.  :-)

I'm not complaining that it's not aggressive enough, but doing
"random" address-range checks just seems fragile.  I'm sure with a bit
of thought, a better (and more general scheme) can be thought of.

One thing that you could definitely do is to use an
exception-table-like approach (see uacess.h), where you'd tag each
instruction which consumes a user-level value and mark it as
potentially MCA triggering.  If you defined a suitable macro (e.g.,
st8.mca), this could be even reasonable and would then capture all
interesting cases reliably.

	--david
