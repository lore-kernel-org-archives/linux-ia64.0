From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 12 Jan 2004 21:26:50 +0000
Subject: Re: [PATCH] sba_iommu update (2.6 version)
Message-Id: <16387.4378.836759.342756@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1073938588.6497.56.camel@patsy.fc.hp.com>
In-Reply-To: <1073938588.6497.56.camel@patsy.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 12 Jan 2004 13:16:29 -0700, Alex Williamson <alex.williamson@hp.com> said:

  Alex> +static SBA_INLINE int
  Alex> +get_iovp_order (unsigned long size)
  Alex> +{
  Alex> +	double d = size - 1;
  Alex> +	long order;
  Alex> +
  Alex> +	__asm__ ("getf.exp %0=%1" : "=r"(order) : "f"(d));
  Alex> +	order = order - iovp_shift - 0xffff + 1;
  Alex> +	if (order < 0)
  Alex> +		order = 0;
  Alex> +	return order;
  Alex> +}

Please avoid inline-asm and use the corresponding intrinsic instead
(ia64_getf_exp(), in this particular case) so that the Intel compiler
remains usable.

Also, looking at it, I suspect we'd be better off using "long double"
instead of "double" to avoid problems with huge values (yeah, probably
doesn't make a difference in practice, but we should avoid propagating
potentially-buggy code; I see get_order() has the same
problem---apparently only ia64_fls() got fixed).

  Alex> +sba_page_override(char *str)

Wouldn't it be cleaner to use lib/cmdline.c:memparse() here?

	--david
