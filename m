From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 Jul 2004 18:43:55 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <16621.38379.377383.933262@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 8 Jul 2004 11:13:20 -0700, Jesse Barnes <jbarnes@engr.sgi.com> said:

  Jesse> And like I've already mentioned, if I revert the whole thing
  Jesse> the kernel boots fine.  Ugg, I'm really starting to dislike
  Jesse> the move of the init_task...

I suppose you Would rather have me undo the virtual mapping of the
kernel?  That's the only "easy" solution I can think of, but that
would be a definite step back in other ways.

	--david
