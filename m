From: Al Viro <viro@zeniv.linux.org.uk>
Date: Tue, 15 Feb 2022 00:48:03 +0000
Subject: Re: [PATCH 11/14] sparc64: remove CONFIG_SET_FS support
Message-Id: <Ygr4Q2/KxfF86ETa@zeniv-ca.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220214163452.1568807-1-arnd@kernel.org>
 <20220214163452.1568807-12-arnd@kernel.org>
In-Reply-To: <20220214163452.1568807-12-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, arnd@arndb.de, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, will@kernel.org, guoren@kernel.org, bcain@codeaurora.org, geert@linux-m68k.org, monstr@monstr.eu, tsbogend@alpha.franken.de, nickhu@andestech.com, green.hu@gmail.com, dinguyen@kernel.org, shorne@gmail.com, deller@gmx.de, mpe@ellerman.id.au, peterz@infradead.org, mingo@redhat.com, mark.rutland@arm.com, hca@linux.ibm.com, dalias@libc.org, davem@davemloft.net, richard@nod.at, x86@kernel.org, jcmvbkbc@gmail.com, ebiederm@xmission.com, akpm@linux-foundation.org, ardb@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org

On Mon, Feb 14, 2022 at 05:34:49PM +0100, Arnd Bergmann wrote:

> -/*
> - * Sparc64 is segmented, though more like the M68K than the I386.
> - * We use the secondary ASI to address user memory, which references a
> - * completely different VM map, thus there is zero chance of the user
> - * doing something queer and tricking us into poking kernel memory.

Actually, this part of comment probably ought to stay - it is relevant
for understanding what's going on (e.g. why is access_ok() always true, etc.)
