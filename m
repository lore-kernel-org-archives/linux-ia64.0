From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 28 Jan 2005 05:22:36 +0000
Subject: Re: [patch] Resched skip_rbs_switch to run 4 cycles faster on McKinley-type cores.
Message-Id: <16889.52252.604395.976163@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501190500.j0J505jY002441@napali.hpl.hp.com>
In-Reply-To: <200501190500.j0J505jY002441@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 28 Jan 2005 14:04:35 +1100, Keith Owens <kaos@sgi.com> said:

  >>  How is this different from the "unw_init_from_interruption" call
  >> that we're doing in mca.c:init_handler_platform()?

  Keith> That only works for the INIT call which uses the current
  Keith> bspstore, MCA uses its own bspstore.

Ah, OK, I understand now what you're after.

Thanks,

	--david

PS: For what it's woth, I did start work on a libunwind-enabled kernel.
