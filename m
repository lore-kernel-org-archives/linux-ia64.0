From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 28 Jan 2005 02:08:18 +0000
Subject: Re: [patch] Resched skip_rbs_switch to run 4 cycles faster on McKinley-type cores.
Message-Id: <16889.40594.988943.699346@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501190500.j0J505jY002441@napali.hpl.hp.com>
In-Reply-To: <200501190500.j0J505jY002441@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 Jan 2005 21:26:18 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> Unwinding across firmware is not an issue here, we have two
  Keith> views of the MCA/INIT context.  One view is "how to return to
  Keith> SAL?", that data is stored outside the stack.  The other view
  Keith> is "what was the cpu doing when the event occurred?".  It is
  Keith> the latter that I am working on.

How is this different from the "unw_init_from_interruption" call that
we're doing in mca.c:init_handler_platform()?

	--david
