From: Arjan van de Ven <arjan@infradead.org>
Date: Tue, 22 Feb 2005 22:03:53 +0000
Subject: Re: [patch -mm series] ia64 specific /dev/mem handlers
Message-Id: <1109109833.6024.109.camel@laptopd505.fenrus.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16923.193.128608.607599@jaguar.mkp.net>
In-Reply-To: <16923.193.128608.607599@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jes Sorensen <jes@trained-monkey.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 2005-02-22 at 04:52 -0500, Jes Sorensen wrote:
> Hi,
> 
> This patch introduces ia64 specific read/write handlers for /dev/mem
> access which is needed to avoid uncached pages to be accessed through
> the cached kernel window which can lead to random corruption. It also
> introduces a new page-flag PG_uncached which will be used to mark the
> uncached pages. I assume this may be useful to other architectures as
> well where the CPU may use speculative reads which conflict with
> uncached access. In addition I moved do_write_mem to be under
> ARCH_HAS_DEV_MEM as it's only ever used if that is defined.
> 
> The patch is needed for the new ia64 special memory driver (mspec -
> former fetchop).


is there ANY valid reason to allow access to cached uses at all?
(eg kernel ram)

why not just disable any such ram access entirely...


