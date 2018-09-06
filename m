From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 06 Sep 2018 08:31:49 +0000
Subject: Re: [RFC PATCH 04/29] mm: remove bootmem allocator implementation.
Message-Id: <20180906083149.GZ14951@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-5-git-send-email-rppt@linux.vnet.ibm.com>
 <20180906073023.GO14951@dhcp22.suse.cz>
In-Reply-To: <20180906073023.GO14951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 06-09-18 09:30:23, Michal Hocko wrote:
> Is there any reason to keep
> 
> ifdef CONFIG_NO_BOOTMEM
> 	obj-y		+= nobootmem.o
> else
> 	obj-y		+= bootmem.o
> endif
> 
> behind?

I can see you have done so in an earlier patch. I have missed that.
-- 
Michal Hocko
SUSE Labs
