From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jan 2005 05:11:18 +0000
Subject: Re: pipe performance regression on ia64
Message-Id: <16877.60406.192245.106565@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501181741.j0IHfGf30058@unix-os.sc.intel.com>
	<Pine.LNX.4.58.0501180951050.8178@ppc970.osdl.org>
	<41ED9D06.1070301@yahoo.com.au>
In-Reply-To: <41ED9D06.1070301@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

>>>>> On Wed, 19 Jan 2005 10:34:30 +1100, Nick Piggin <nickpiggin@yahoo.com.au> said:

  Nick> David I remember you reporting a pipe bandwidth regression,
  Nick> and I had a patch for it, but that hurt other workloads, so I
  Nick> don't think we ever really got anywhere. I've recently begun
  Nick> having another look at the multiprocessor balancer, so
  Nick> hopefully I can get a bit further with it this time.

While it may be worthwhile to improve the scheduler, it's clear that
there isn't going to be a trivial "fix" for this issue, especially
since it's not even clear that anything is really broken.  Independent
of the scheduler work, it would be very useful to have a pipe
benchmark which at least made the dependencies on the scheduler
obvious.  So I think improving the scheduler and improving the LMbench
pipe benchmark are entirely complementary.

	--david

