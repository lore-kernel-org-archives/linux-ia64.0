From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 Jan 2005 06:50:07 +0000
Subject: Re: [patch] Resched skip_rbs_switch to run 4 cycles faster on McKinley-type cores.
Message-Id: <16879.21663.445128.380686@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501190500.j0J505jY002441@napali.hpl.hp.com>
In-Reply-To: <200501190500.j0J505jY002441@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 Jan 2005 09:25:35 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> Damn, I was in the middle of developing a patch against this
  Keith> area :(.

Oops.

  Keith> Instead of being garbage when the interrupted code was in the
  Keith> kernel, ar_bspstore and ar_rnat are set to zero.  The test
  Keith> for "do I skip_rbs_switch" changes from pUStk to "is saved
  Keith> ar_bspstore non-zero".

Wouldn't this prevent user-level code from setting ar.bspstore to
zero?  I'm not sure we should nail that into the kernel (by default
the first page is a NaT page, so it's not likely to be a real problem
as of today).

  Keith> Comments?

Libunwind does support multiple register backing-stores, but since we
cannot unwind across firmware, I'm not sure whether this by itself
would make your life easier.  If it would, let me know.

	--david
