From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 18 Feb 2022 18:07:07 +0000
Subject: Re: [PATCH v2 13/18] uaccess: generalize access_ok()
Message-Id: <CALCETrWTB65vJXsQTPd_o7BRoSU=uqD0pFzKS+r4YgDuiCCqaQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220216131332.1489939-1-arnd@kernel.org> <20220216131332.1489939-14-arnd@kernel.org>
 <CALCETrVOvYPN4_6hS8wpm2v9bGZupZ5x4=vZAseG57OUgvLGfw@mail.gmail.com> <93a1ee797e9d4f789dff85a3c0f0c232@AcuMS.aculab.com>
In-Reply-To: <93a1ee797e9d4f789dff85a3c0f0c232@AcuMS.aculab.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@aculab.com>
Cc: Arnd Bergmann <arnd@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, "arnd@arndb.de" <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "will@kernel.org" <will@kernel.org>, "guoren@kernel.org" <guoren@kernel.org>, "bcain@codeaurora.org" <bcain@codeaurora.org>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "monstr@monstr.eu" <monstr@monstr.eu>, "tsbogend@alpha.franken.de" <tsbogend@alpha.franken.de>, "nickhu@andestech.com" <nickhu@andestech.com>, "green.hu@gmail.com" <green.hu@gmail.com>, "dinguyen@kernel.org" <dinguyen@kernel.org>, "shorne@gmail.com" <shorne@gmail.com>, "deller@gmx.de" <deller@gmx.de>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, "peterz@infradead.org" <peterz@infradead.org>, "mingo@redhat.com" <mingo@redhat.com>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "hca@linux.ibm.com" <hca@linux.ibm.com>, "dalias@libc.org" <dalias@libc.org>, "davem@davemloft.net" <davem@davemloft.net>, "richard@nod.at" <richard@nod.at>, "x86@kernel.org" <x86@kernel.org>, "jcmvbkbc@gmail.com" <jcmvbkbc@gmail.com>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "ardb@kernel.org" <ardb@kernel.org>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-csky@vger.kernel.org" <linux-csky@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-um@lists.infradead.org" <linux-um@lists.infradead.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>

On Fri, Feb 18, 2022 at 1:30 AM David Laight <David.Laight@aculab.com> wrote:
>
> From: Andy Lutomirski
> > Sent: 17 February 2022 19:15
> ...
> > This isn't actually optimal.  On x86, TASK_SIZE_MAX is a bizarre
> > constant that has a very specific value to work around a bug^Wdesign
> > error^Wfeature of Intel CPUs.  TASK_SIZE_MAX is the maximum address at
> > which userspace is permitted to allocate memory, but there is a huge
> > gap between user and kernel addresses, and any value in the gap would
> > be adequate for the comparison.  If we wanted to optimize this, simply
> > checking the high bit (which x86 can do without any immediate
> > constants at all) would be sufficient and, for an access known to fit
> > in 32 bits, one could get even fancier and completely ignore the size
> > of the access.  (For accesses not known to fit in 32 bits, I suspect
> > some creativity could still come up with a construction that's
> > substantially faster than the one in your patch.)
> >
> > So there's plenty of room for optimization here.
> >
> > (This is not in any respect a NAK -- it's just an observation that
> > this could be even better.)
>
> For 64bit arch that use the top bit to separate user/kernel
> you can test '(addr | size) >> 62)'.
> The compiler optimises out constant sizes.
>
> This has all been mentioned a lot of times.
> You do get different fault types.
>
> OTOH an explicit check for constant size (less than something big)
> can use the cheaper test of the sign bit.
> Big constant sizes could be compile time errors.

The different fault type issue may well be a real problem.  Right now
the core x86 fault code reserves the right to grouch if we get #GP
instead of #PF.  We could change that.
