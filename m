From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jan 2005 22:20:21 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <16878.56613.537997.200566@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Jan 2005 14:16:28 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> No, it still depends on pgprot_writecombined, which is ia64
  Jesse> specific.

Not exactly ia64-specific, but yeah, I see x86 doesn't have it (I
thought it did).

  Jesse> x86 has its own way to set the wc bit and afaik doesn't have
  Jesse> the same aliasing issues that ia64 has.

In my opinion, an EFI-based system should respect the
attribute-restrictions specified in the memory-map.

	--david
