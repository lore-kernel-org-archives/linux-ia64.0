From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 14 Feb 2022 17:02:13 +0000
Subject: Re: [PATCH 04/14] x86: use more conventional access_ok() definition
Message-Id: <YgqLFYqIqkIsNC92@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220214163452.1568807-1-arnd@kernel.org>
 <20220214163452.1568807-5-arnd@kernel.org>
In-Reply-To: <20220214163452.1568807-5-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, arnd@arndb.de, linux-kernel@vger.kernel.org, mark.rutland@arm.com, dalias@libc.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, peterz@infradead.org, jcmvbkbc@gmail.com, guoren@kernel.org, sparclinux@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-riscv@lists.infradead.org, will@kernel.org, ardb@kernel.org, linux-s390@vger.kernel.org, bcain@codeaurora.org, deller@gmx.de, x86@kernel.org, linux@armlinux.org.uk, linux-csky@vger.kernel.org, mingo@redhat.com, geert@linux-m68k.org, linux-snps-arc@lists.infradead.org, linux-xtensa@linux-xtensa.org, hca@linux.ibm.com, linux-alpha@vger.kernel.org, linux-um@lists.infradead.org, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, green.hu@gmail.com, shorne@gmail.com, linux-arm-kernel@lists.infradead.org, monstr@monstr.eu, tsbogend@alpha.franken.de, linux-parisc@vger.kernel.org, nickhu@andestech.com, linux-mips@vger.kernel.org, dinguyen@kernel.org, ebiederm@xmission.com, richard@nod.at, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net

On Mon, Feb 14, 2022 at 05:34:42PM +0100, Arnd Bergmann wrote:
> +#define __range_not_ok(addr, size, limit)	(!__access_ok(addr, size))
> +#define __chk_range_not_ok(addr, size, limit)	(!__access_ok((void __user *)addr, size))

Can we just kill these off insted of letting themm obsfucate the code?
