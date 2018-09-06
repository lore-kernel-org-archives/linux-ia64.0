From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 06 Sep 2018 07:30:23 +0000
Subject: Re: [RFC PATCH 04/29] mm: remove bootmem allocator implementation.
Message-Id: <20180906073023.GO14951@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-5-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1536163184-26356-5-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 05-09-18 18:59:19, Mike Rapoport wrote:
> All architectures have been converted to use MEMBLOCK + NO_BOOTMEM. The
> bootmem allocator implementation can be removed.

\o/

Is there any reason to keep

ifdef CONFIG_NO_BOOTMEM
	obj-y		+= nobootmem.o
else
	obj-y		+= bootmem.o
endif

behind?

> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/bootmem.h |  16 -
>  mm/bootmem.c            | 811 ------------------------------------------------
>  2 files changed, 827 deletions(-)
>  delete mode 100644 mm/bootmem.c
-- 
Michal Hocko
SUSE Labs
