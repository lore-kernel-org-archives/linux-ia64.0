From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 Jan 2005 17:01:09 +0000
Subject: Re: [patch] Resched skip_rbs_switch to run 4 cycles faster on McKinley-type cores.
Message-Id: <16879.58325.346809.958391@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501190500.j0J505jY002441@napali.hpl.hp.com>
In-Reply-To: <200501190500.j0J505jY002441@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 Jan 2005 21:26:18 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> It would help, if libunwind were in the kernel.

OK, it does sound like I need to get going with this.  Fortunately,
it's nearing the top of my to-do-list.  I'll see if I can get this
going next week.

  Keith> One side effect of this change is that the unwinder needs an
  Keith> MCA/INIT safe allocator.

Libunwind already has that.  Need to double-check that it's MCA/INIT safe,
but if it isn't already, it should be real close.

	--david
