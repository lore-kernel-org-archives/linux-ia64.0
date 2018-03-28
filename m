From: Tony Luck <tony.luck@intel.com>
Date: Wed, 28 Mar 2018 17:57:11 +0000
Subject: Re: [PATCH] docs/memory-barriers.txt: Fix broken DMA vs MMIO ordering example
Message-Id: <CA+8MBb+61AhMkbo8xtd3Y0fY8xRUPD+kUsEvWgOz94KGEuovOw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1522156287-15169-1-git-send-email-will.deacon@arm.com>
 <20180327150252.GN3675@linux.vnet.ibm.com> <c93ed5db-8cfd-1258-3396-62ca2076c44d@codeaurora.org>
In-Reply-To: <c93ed5db-8cfd-1258-3396-62ca2076c44d@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sinan Kaya <okaya@codeaurora.org>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Arnd Bergmann <arnd@arndb.de>, Jason Gunthorpe <jgg@ziepe.ca>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Wed, Mar 28, 2018 at 6:02 AM, Sinan Kaya <okaya@codeaurora.org> wrote:
> +linux-ia64
> Does IA64 follow this requirement? If not, is implementation planned?
>
> "no wmb() before writel()"
>
> Linus asked us to get rid of wmb() in front of writel() for UC memory.
> Just checking that we are not breaking anything for IA64.

We should be OK on ia64, writel() uses a cast to:

 *(volatile unsigned int __force *)

which the compiler takes as a request to use a "st4.rel" instruction
(meaning "store with release semantics"). So the value stored will
be visible to anything that follows.

-Tony
