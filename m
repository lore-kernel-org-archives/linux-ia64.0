From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 13 May 2004 22:36:23 +0000
Subject: Re: [PATCH] fix "timer tick before it's due"
Message-Id: <16547.63591.956029.201518@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405121721.30863.bjorn.helgaas@hp.com>
In-Reply-To: <200405121721.30863.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 13 May 2004 15:25:31 -0600, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> I agree.  How about this (same as the first patch, plus the
  Bjorn> BUG_ON() and removal of the "jumped tick" check):

Looks great to me (modulo a change to ia64_get_itv() to drop ia64_srlz_d()).

Thanks!

	--david
