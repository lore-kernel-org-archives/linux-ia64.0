From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 10 Feb 2004 22:57:17 +0000
Subject: Re: [patch] 2.4.25-pre8, 2.6.2-rc2 mca.c - pass irq_safe around
Message-Id: <16425.25037.798727.698612@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <9337.1076049423@kao2.melbourne.sgi.com>
In-Reply-To: <9337.1076049423@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 06 Feb 2004 17:37:03 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> The patch is against 2.4.25-pre8 bk.  It also applies to
  Keith> 2.6.2-rc2 bk (with some fuzz and offsets), after applying my
  Keith> previous 6 patches to 2.6.2-rc2 mca.c.

  Keith> Patches from Ben Woodward to calculate irq_safe once and pass
  Keith> it around.

I applied the patch but I'm wondering what happens if someone adds a
new SAL_INFO_TYPE which isn't irq-safe.  Wouldn't it be safer to flip
things around and check sal_info_type against known-to-be-safe values?

	--david
