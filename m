From: Christoph Hellwig <hch@lst.de>
Date: Wed, 13 May 2020 06:23:18 +0000
Subject: Re: [PATCH 19/31] riscv: use asm-generic/cacheflush.h
Message-Id: <20200513062318.GA24133@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200510075510.987823-20-hch@lst.de> <mhng-8adbedbc-0f91-4291-9471-2df5eb7b802b@palmerdabbelt-glaptop1>
In-Reply-To: <mhng-8adbedbc-0f91-4291-9471-2df5eb7b802b@palmerdabbelt-glaptop1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Palmer Dabbelt <palmer@dabbelt.com>
Cc: Christoph Hellwig <hch@lst.de>, akpm@linux-foundation.org, Arnd Bergmann <arnd@arndb.de>, zippel@linux-m68k.org, linux-arch@vger.kernel.org, linux-xtensa@linux-xtensa.org, monstr@monstr.eu, jeyu@kernel.org, linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, x86@kernel.org, linux-um@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-riscv@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On Tue, May 12, 2020 at 04:00:26PM -0700, Palmer Dabbelt wrote:
> Reviewed-by: Palmer Dabbelt <palmerdabbelt@google.com>
> Acked-by: Palmer Dabbelt <palmerdabbelt@google.com>
>
> Were you trying to get these all in at once, or do you want me to take it into
> my tree?

Except for the small fixups at the beginning of the series this needs
to go in together.  I'll have to do at least another resend, and after
that I hope Andrew is going to pick it up.
