From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 06 Jan 2005 20:00:11 +0000
Subject: Re: [PATCH] cleanup swiotlb.c a bit
Message-Id: <16861.39115.110083.6350@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060945.12364.jbarnes@engr.sgi.com>
In-Reply-To: <200501060945.12364.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 6 Jan 2005 11:50:56 -0800, Jesse Barnes <jbarnes@engr.sgi.com> said:

  >>  It's not opinion, it's reality.  Unless someone goes through all
  >> the files in the top-level directories and formats them to 80
  >> cols, this won't change.

  Jesse> I'd be happy to do that if you're ok with it.

Eh, I'm talking about linux/kernel/* etc, so it's really Andrew and
Linus who'd have to be OK with it.

If you can fix those, I'd be happy to adjust the ia64 files to fit
within 80 cols.

  Jesse> The long lines have always irritated me a little.  I think I
  Jesse> understand why you like them though--with long lines you can
  Jesse> fit slightly more code on the screen vertically, which can be
  Jesse> a help, but I don't think they're common enough for that to
  Jesse> be very compelling...

I don't particularly like 100 cols.  I'd be happy if all (major) Linux
kernel files fit into 80 cols, it's just that in reality, you need 100
cols to look at most important kernel files.

	--david
