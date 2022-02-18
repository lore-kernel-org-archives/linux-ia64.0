From: Christoph Hellwig <hch@lst.de>
Date: Fri, 18 Feb 2022 06:35:49 +0000
Subject: Re: [PATCH v2 14/18] lib/test_lockup: fix kernel pointer check for separate address spaces
Message-Id: <20220218063549.GJ22576@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220216131332.1489939-1-arnd@kernel.org> <20220216131332.1489939-15-arnd@kernel.org>
In-Reply-To: <20220216131332.1489939-15-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, arnd@arndb.de, linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk, linux@armlinux.org.uk, will@kernel.org, guoren@kernel.org, bcain@codeaurora.org, geert@linux-m68k.org, monstr@monstr.eu, tsbogend@alpha.franken.de, nickhu@andestech.com, green.hu@gmail.com, dinguyen@kernel.org, shorne@gmail.com, deller@gmx.de, mpe@ellerman.id.au, peterz@infradead.org, mingo@redhat.com, mark.rutland@arm.com, hca@linux.ibm.com, dalias@libc.org, davem@davemloft.net, richard@nod.at, x86@kernel.org, jcmvbkbc@gmail.com, ebiederm@xmission.com, akpm@linux-foundation.org, ardb@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org

On Wed, Feb 16, 2022 at 02:13:28PM +0100, Arnd Bergmann wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> 
> test_kernel_ptr() uses access_ok() to figure out if a given address
> points to user space instead of kernel space. However on architectures
> that set CONFIG_ALTERNATE_USER_ADDRESS_SPACE, a pointer can be valid
> for both, and the check always fails because access_ok() returns true.
> 
> Make the check for user space pointers conditional on the type of
> address space layout.

What is this code even trying to do?  It looks extremly broken.
