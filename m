From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 19 Feb 2004 01:14:59 +0000
Subject: Re: [PATCH] 2.4.25: BUG(): Use guard page instead of page 0
Message-Id: <16436.3603.827198.821944@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040218221302.GA87364@dragonfly.csd.sgi.com>
In-Reply-To: <20040218221302.GA87364@dragonfly.csd.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 18 Feb 2004 14:13:03 -0800, Jason Uhlenkott <jasonuhl@sgi.com> said:

  Jason> The ia64 BUG macro deliberately writes to address 0 in order to
  Jason> trigger a page fault and an Oops.  This won't work if the process has
  Jason> mapped something into page zero:  We'll just print the "kernel BUG"
  Jason> message and continue (after having stomped on whatever user memory was
  Jason> at address 0).

  Jason> A solution is to write to the guard page in region 5, which is
  Jason> guaranteed to trigger a page fault.

The 2.6 kernel uses __builtin_trap(), which is even better (when available).

	--david
