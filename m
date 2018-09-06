From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 06 Sep 2018 09:15:38 +0000
Subject: Re: [RFC PATCH 00/29] mm: remove bootmem allocator
Message-Id: <20180906091538.GN14951@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 05-09-18 18:59:15, Mike Rapoport wrote:
[...]
>  325 files changed, 846 insertions(+), 2478 deletions(-)
>  delete mode 100644 include/linux/bootmem.h
>  delete mode 100644 mm/bootmem.c
>  delete mode 100644 mm/nobootmem.c

This is really impressive! Thanks a lot for working on this. I wish we
could simplify the memblock API as well. There are just too many public
functions with subtly different semantic and barely any useful
documentation.

But even this is a great step forward!
-- 
Michal Hocko
SUSE Labs
