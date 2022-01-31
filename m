From: Oscar Salvador <osalvador@suse.de>
Date: Mon, 31 Jan 2022 09:40:43 +0000
Subject: Re: [PATCH RFC v1] drivers/base/node: consolidate node device subsystem initialization in node_dev_i
Message-Id: <20220131094041.GA15392@linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220128151540.164759-1-david@redhat.com>
 <YfeARpenqPii1WQH@localhost.localdomain>
 <3be2e20c-f0b9-c080-adf4-b0e17c046eb0@redhat.com>
In-Reply-To: <3be2e20c-f0b9-c080-adf4-b0e17c046eb0@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "Rafael J. Wysocki" <rafael@kernel.org>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On Mon, Jan 31, 2022 at 08:48:54AM +0100, David Hildenbrand wrote:
> Hi Oscar,

Hi David :-),

> Right, and the idea is that the online state of nodes (+ node/zone
> ranges) already has to be known at that point in time, because
> otherwise, we'd be in bigger trouble.

Yeah, I wanted to check where exactly did we mark the nodes online,
and for the few architectures I checked it happens in setup_arch(),
which is called very early in start_kernel(), while driver_init()
gets called through arch_call_rest_init(), which happens at the end
of the function.

I am not sure whether we want to remark that somehow in the changelog,
so it is crystal clear that by the time the node_dev_init() gets called,
we already set the nodes online.

Anyway, just saying, but is fine as is.
 

-- 
Oscar Salvador
SUSE Labs
