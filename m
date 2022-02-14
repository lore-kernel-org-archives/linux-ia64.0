From: Arnd Bergmann <arnd@kernel.org>
Date: Mon, 14 Feb 2022 19:40:07 +0000
Subject: Re: [PATCH 10/14] uaccess: remove most CONFIG_SET_FS users
Message-Id: <CAK8P3a3eOw=QpxWFnODE61EFt8oGPJ7dcusfbPSD1vdEsUmekQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220214163452.1568807-1-arnd@kernel.org> <20220214163452.1568807-11-arnd@kernel.org>
 <YgqL/NJ3YHEAhj4i@infradead.org>
In-Reply-To: <YgqL/NJ3YHEAhj4i@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Max Filippov <jcmvbkbc@gmail.com>, Guo Ren <guoren@kernel.org>, sparclinux <sparclinux@vger.kernel.org>, "open list:QUALCOMM HEXAGON..." <linux-hexagon@vger.kernel.org>, linux-riscv <linux-riscv@lists.infradead.org>, Will Deacon <will@kernel.org>, Ard Biesheuvel <ardb@kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Brian Cain <bcain@codeaurora.org>, Helge Deller <deller@gmx.de>, the arch/x86 maintainers <x86@kernel.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, linux-csky@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "open list:SYNOPSYS ARC ARCHITECTURE" <linux-snps-arc@lists.infradead.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, Heiko Carstens <hca@linux.ibm.com>, alpha <linux-alpha@vger.kernel.org>, linux-um <linux-um@lists.infradead.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Openrisc <openrisc@lists.librecores.org>, Greentime Hu <green.hu@gmail.com>, Stafford Horne <shorne@gmail.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Michal Simek <monstr@monstr.eu>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Parisc List <linux-parisc@vger.kernel.org>, Nick Hu <nickhu@andestech.com>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, Dinh Nguyen <dinguyen@kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Richard Weinberger <richard@nod.at>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, David Miller <davem@davemloft.net>

On Mon, Feb 14, 2022 at 6:06 PM Christoph Hellwig <hch@infradead.org> wrote:
>
> On Mon, Feb 14, 2022 at 05:34:48PM +0100, Arnd Bergmann wrote:
> > From: Arnd Bergmann <arnd@arndb.de>
> >
> > On almost all architectures, there are no remaining callers
> > of set_fs(), so CONFIG_SET_FS can be disabled, along with
> > removing the thread_info field and any references to it.
> >
> > This turns access_ok() into a cheaper check against TASK_SIZE_MAX.
>
> Wouldn't it make more sense to just merge this into the last patch?

Yes, sounds good. I wasn't sure at first if there is enough buy-in to get
all architectures cleaned up, and I hadn't done the ia64 patch, so it
seemed more important to do this part early, but now it seems that it
will all go in at the same time, so doing this as part of a big removal
at the end makes sense.

        Arnd
