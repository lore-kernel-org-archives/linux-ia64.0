From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 09 Feb 2005 21:11:54 +0000
Subject: Re: PATCH: Fix 2.6 kernel ia64 directives
Message-Id: <16906.31898.389410.288849@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050202221918.GA7973@lucon.org>
In-Reply-To: <20050202221918.GA7973@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 09 Feb 2005 12:10:13 -0800, James E Wilson <wilson@tuliptree.org> said:

  Jim> It is important that the assembler give an error if a problem is
  Jim> detected, as otherwise a serious latent bug may go unfixed.  I we give a
  Jim> warning, then people may not notice it and fix their code.

  Jim> However, I do understand that there is some inconvenience here.  I have
  Jim> no problem with emitting a warning temporarily to give people a chance
  Jim> to migrate.

Yes, that's really all I'm asking for.

I'm _very_ happy to see that the unwind directives are getting
sanity-checking.  Not having this has bitten me before on more than
one occasion and we all know that the number of people that check
unwind-info with readelf -u can be counted on one hand, so like you
say, that's very important.  But we can't expect existing code to get
fixed over night, hence we should allow for a grace period.  If the
code doesn't get fixed during that period, at least we can say "you
were warned"...

  Jim> In fact, I believe I will have to use a warning for now because
  Jim> these changes break gcc -pg, and this is not easy to fix as it
  Jim> will also require glibc changes.  I already have a patch from
  Jim> HJ to do this, I just need to review it.

OK, that sounds great.

Thanks,

	--david
