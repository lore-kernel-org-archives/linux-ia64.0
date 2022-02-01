From: Anatoly Pugachev <matorola@gmail.com>
Date: Tue, 01 Feb 2022 10:02:45 +0000
Subject: Re: [PATCH RFC v1] drivers/base/node: consolidate node device subsystem initialization in node_dev_i
Message-Id: <CADxRZqx_rAkwFVwSc1ohm-RqKD=-pcBsR+rBrRaw9KazQncANQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220128151540.164759-1-david@redhat.com>
In-Reply-To: <20220128151540.164759-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Hildenbrand <david@redhat.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Michal Hocko <mhocko@suse.com>, Oscar Salvador <osalvador@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "Rafael J. Wysocki" <rafael@kernel.org>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390 <linux-s390@vger.kernel.org>, linux-sh@vger.kernel.org, Sparc kernel list <sparclinux@vger.kernel.org>

On Mon, Jan 31, 2022 at 2:11 PM David Hildenbrand <david@redhat.com> wrote:
>
> ... and call node_dev_init() after memory_dev_init() from driver_init(),
> so before any of the existing arch/subsys calls. All online nodes should
> be known at that point.
>
> This is in line with memory_dev_init(), which initializes the memory
> device subsystem and creates all memory block devices.
>
> Similar to memory_dev_init(), panic() if anything goes wrong, we don't
> want to continue with such basic initialization errors.
>
> The important part is that node_dev_init() gets called after
> memory_dev_init() and after cpu_dev_init(), but before any of the
> relevant archs call register_cpu() to register the new cpu device under
> the node device. The latter should be the case for the current users
> of topology_init().
>
> RFC because I tested only on x86-64 and s390x, I think I cross-compiled all
> applicable architectures except riscv and sparc.

Compiled and boot tested on sparc.

Tested-by: Anatoly Pugachev <matorola@gmail.com> (sparc64)
