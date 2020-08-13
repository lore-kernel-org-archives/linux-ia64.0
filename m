From: Matthew Wilcox <willy@infradead.org>
Date: Thu, 13 Aug 2020 21:36:31 +0000
Subject: Re: [PATCH v5] arch/ia64: Restore arch-specific pgd_offset_k implementation
Message-Id: <20200813213631.GQ17456@casper.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200813205521.5405-1-rppt@kernel.org>
In-Reply-To: <20200813205521.5405-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>
Cc: Jessica Clarke <jrtc27@jrtc27.com>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Anatoly Pugachev <matorola@gmail.com>, Sergei Trofimovich <slyfox@gentoo.org>, linux-mm@kvack.org, Frank Scheiner <frank.scheiner@web.de>, Mike Rapoport <rppt@linux.ibm.com>

On Thu, Aug 13, 2020 at 11:55:21PM +0300, Mike Rapoport wrote:
> +/*
> + * In the kernel's mapped region we know everything is in region number 5, so
> + * as an optimisation its PGD already points to the area for that region.

Is it actually an optimisation?  Are there any benchmarks where this
makes any difference whatsoever?  Or should the comment be closer to

/* ia64 is gratuitously different.  Cope with it. */

I might suggest that pgd be changed to be the same as every other pgd
in the system, and every other architecture.
