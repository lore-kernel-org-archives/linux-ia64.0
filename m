From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 05 Mar 2004 00:06:30 +0000
Subject: Re: [PATCH] 2.4.25: BUG(): Use guard page instead of page 0
Message-Id: <16455.50310.822073.694110@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040218221302.GA87364@dragonfly.csd.sgi.com>
In-Reply-To: <20040218221302.GA87364@dragonfly.csd.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 4 Mar 2004 16:05:31 -0800, David Mosberger <davidm@linux.hpl.hp.com> said:

  David> I don't think it's worth changing (2.9x is out for 2.6
  David> anyhow, and I doubt anyone is using GCC 3.0 for real work; if
  David> you do, you're probably in lots of trouble for other
  David> reasons!).  Besides, one disadvantage of using "break 0" is
  David> that it will make Ski stop immediately, which isn't what you
  David> want.

Never mind.  The Ski argument is BS of course... (since that's what
__builtin_trap() uses... ;-)

	--david
