From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 31 May 2003 03:16:40 +0000
Subject: Re: [Linux-ia64] sigaltstack and ar.bspstore
Message-Id: <marc-linux-ia64-105590723706103@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706086@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706086@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 31 May 2003 11:31:18 +1000, Matt Chapman <matthewc@cse.unsw.edu.au> said:

  Matt> I wasn't suggesting changing the layout, I was suggesting
  Matt> using one of the reserved slots.  Unless you're referring to
  Matt> software that changes sc_ar_bsp...

Yes, that's what I was referring to.

  Matt> I don't think there's currently enough information available
  Matt> upon return from the signal handler to decide whether to point
  Matt> bspstore at slot 63 or 0.  It wouldn't be safe to always go
  Matt> for slot 63 because it might be beyond the start of the RBS.

I'll have to think about this some more.  Especially to make sure that
there aren't any other places were we (I) made the assumption that
bspstore never points to an RNaT slot.  But it will take me a while
before I get to it (in case I forget or you come up with a great
solution, please ping me... ;-).

	--david

