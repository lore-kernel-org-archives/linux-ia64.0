From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 15 Jul 2004 20:21:35 +0000
Subject: RE: free bootmem feedback patch
Message-Id: <16630.59215.559219.214126@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F46962.4090604@sgi.com>
In-Reply-To: <40F46962.4090604@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 15 Jul 2004 12:11:07 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> Notes and Caveats: 1) Is there a define someplace for
  Tony> log2(BITS_PER_LONG)?  I couldn't find one, which is why I
  Tony> calculate the "order" in this patch.

BITS_PER_LONG is a power-of-two, so ffs() will do.  For more general
cases, you may want asm/page.h:get_order() instead.

	--david
