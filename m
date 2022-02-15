From: Christoph Hellwig <hch@lst.de>
Date: Tue, 15 Feb 2022 06:29:42 +0000
Subject: Re: [PATCH 09/14] m68k: drop custom __access_ok()
Message-Id: <20220215062942.GA12551@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220214163452.1568807-1-arnd@kernel.org> <20220214163452.1568807-10-arnd@kernel.org> <Ygr11RGjj3C9uAUg@zeniv-ca.linux.org.uk>
In-Reply-To: <Ygr11RGjj3C9uAUg@zeniv-ca.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Arnd Bergmann <arnd@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, arnd@arndb.de, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, will@kernel.org, guoren@kernel.org, bcain@codeaurora.org, geert@linux-m68k.org, monstr@monstr.eu, tsbogend@alpha.franken.de, nickhu@andestech.com, green.hu@gmail.com, dinguyen@kernel.org, shorne@gmail.com, deller@gmx.de, mpe@ellerman.id.au, peterz@infradead.org, mingo@redhat.com, mark.rutland@arm.com, hca@linux.ibm.com, dalias@libc.org, davem@davemloft.net, richard@nod.at, x86@kernel.org, jcmvbkbc@gmail.com, ebiederm@xmission.com, akpm@linux-foundation.org, ardb@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org

On Tue, Feb 15, 2022 at 12:37:41AM +0000, Al Viro wrote:
> Perhaps simply wrap that sucker into #ifdef CONFIG_CPU_HAS_ADDRESS_SPACES
> (and trim the comment down to "coldfire and 68000 will pick generic
> variant")?

I wonder if we should invert CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE,
select the separate address space config for s390, sparc64, non-coldfire
m68k and mips with EVA and then just have one single access_ok for
overlapping address space (as added by Arnd) and non-overlapping ones
(always return true).
