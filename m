From: Christoph Hellwig <hch@lst.de>
Date: Mon, 14 Feb 2022 20:00:11 +0000
Subject: Re: [PATCH 04/14] x86: use more conventional access_ok() definition
Message-Id: <20220214200011.GA3786@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220214163452.1568807-1-arnd@kernel.org>
 <20220214163452.1568807-5-arnd@kernel.org> <YgqLFYqIqkIsNC92@infradead.org>
 <CAK8P3a1F3JaYaJPy9bSCG1+YV6EN05PE0DbwpD_GT1qRwFSJ-w@mail.gmail.com>
In-Reply-To: <CAK8P3a1F3JaYaJPy9bSCG1+YV6EN05PE0DbwpD_GT1qRwFSJ-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, sparclinux <sparclinux@vger.kernel.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>, Will Deacon <will@kernel.org>, Ard Biesheuvel <ardb@kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Brian Cain <bcain@codeaurora.org>, Helge Deller <deller@gmx.de>, the arch/x86 maintainers <x86@kernel.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, linux-csky@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, Heiko Carstens <hca@linux.ibm.com>, alpha <linux-alpha@vger.kernel.org>, linux-um <linux-um@lists.infradead.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Openrisc <openrisc@lists.librecores.org>, Greentime Hu <green.hu@gmail.com>, Stafford Horne <shorne@gmail.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Parisc List <linux-parisc@vger.kernel.org>, Nick Hu <nickhu@andestech.com>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Dinh Nguyen <dinguyen@kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Richard Weinberger <richard@nod.at>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, David Miller <davem@davemloft.net>, Al Viro <viro@zeniv.linux.org.uk>

On Mon, Feb 14, 2022 at 08:45:52PM +0100, Arnd Bergmann wrote:
> As Al pointed out, they turned out to be necessary on sparc64, but the only
> definitions are on sparc64 and x86, so it's possible that they serve a similar
> purpose here, in which case changing the limit from TASK_SIZE to
> TASK_SIZE_MAX is probably wrong as well.
> 
> So either I need to revert the original definition as I did on sparc64, or
> they can be removed completely. Hopefully Al or the x86 maintainers
> can clarify.

Looking at the x86 users I think:

 - valid_user_frame should go away and the caller should use get_user
   instead of __get_user
 - the one in copy_code can just go away, as there is another check
   in copy_from_user_nmi
 - copy_stack_frame should just use access_ok
 - as does copy_from_user_nmi

but yes, having someone who actually knows this code look over it
would be very helpful.
