From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 20 Oct 2004 15:29:57 +0000
Subject: Re: [PATCH] Add key management syscalls to non-i386 archs
Message-Id: <20041020152957.GA21774@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <3506.1098283455@redhat.com>
In-Reply-To: <3506.1098283455@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Howells <dhowells@redhat.com>
Cc: torvalds@osdl.org, akpm@osdl.org, linux-kernel@vger.kernel.org, discuss@x86-64.org, sparclinux@vger.kernel.org, linuxppc64-dev@ozlabs.org, linux-m68k@vger.kernel.org, linux-sh@m17n.org, linux-arm-kernel@lists.arm.linux.org.uk, parisc-linux@parisc-linux.org, linux-ia64@vger.kernel.org, linux-390@vm.marist.edu, linux-mips@linux-mips.org

> Hi Linus, Andrew,
> 
> The attached patch adds syscalls for almost all archs (everything barring
> m68knommu which is in a real mess, and i386 which already has it).
> 
> It also adds 32->64 compatibility where appropriate.

Umm, that patch added the damn multiplexer that had been vetoed multiple
times.  Why did this happen?

