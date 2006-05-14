From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 14 May 2006 21:35:56 +0000
Subject: Re: + git-hdrcleanup-vs-git-klibc-on-ia64.patch added to -mm tree
Message-Id: <1147642556.2729.6.camel@shinybook.infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1147632661.2551.5.camel@shinybook.infradead.org>
In-Reply-To: <1147632661.2551.5.camel@shinybook.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 2006-05-14 at 22:15 +0100, Christoph Hellwig wrote:
> Using byte swizzling instrincts I supposed.  On the other hand asm/byteorder.h
> really shouldn't be user-exposed to start with. 

A whole bunch of things include byteorder.h 

On Sun, 2006-05-14 at 22:17 +0100, Christoph Hellwig wrote:
> elf.h shouldn't be exported to userspace at all.  there's a separate incarnation
> of elf.h in userland, so anyone importing the kernel one is plain stupid.
> 
> similarly no one should be using page.h, there is nothing in there userspace
> should ever look at

ucontext.h includes elf.h for elf_gregset_t. 
elf.h includes page.h (probably for PAGE_SIZE).

Yes, they do want cleaning up -- but I want the first set of stuff in
the hdrcleanup git tree to be _entirely_ simple and uncontentious. We
can get on to the more interesting stuff later.

-- 
dwmw2

