From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jan 2005 22:25:52 +0000
Subject: Re: pgprot_writecombine & shub 1.x
Message-Id: <16878.56944.84165.478388@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501111200.02504.jbarnes@sgi.com>
In-Reply-To: <200501111200.02504.jbarnes@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 19 Jan 2005 14:22:56 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> On Wednesday, January 19, 2005 2:20 pm, David Mosberger
  Jesse> wrote:
  >> In my opinion, an EFI-based system should respect the
  >> attribute-restrictions specified in the memory-map.

  Jesse> That makes sense to me.  Seems like we could use a whole new
  Jesse> arch abstraction for setting memory attributes (wc and
  Jesse> uncached at the very least) on page ranges, but that's a much
  Jesse> bigger task.

Absolutely.  Perhaps it would make sense to clean this up once the
hot-plug stuff has settled down?

	--david
