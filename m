From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 20 Oct 2004 18:18:50 +0000
Subject: Re: [PATCH] Add key management syscalls to non-i386 archs
Message-Id: <20041020181850.GA23979@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <3506.1098283455@redhat.com> <20041020152957.GA21774@infradead.org> <20041020105027.54bf9e89.akpm@osdl.org>
In-Reply-To: <20041020105027.54bf9e89.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Hellwig <hch@infradead.org>, dhowells@redhat.com, torvalds@osdl.org, linux-kernel@vger.kernel.org, discuss@x86-64.org, sparclinux@vger.kernel.org, linuxppc64-dev@ozlabs.org, linux-m68k@vger.kernel.org, linux-sh@m17n.org, linux-arm-kernel@lists.arm.linux.org.uk, parisc-linux@parisc-linux.org, linux-ia64@vger.kernel.org, linux-390@vm.marist.edu, linux-mips@linux-mips.org

On Wed, Oct 20, 2004 at 10:50:27AM -0700, Andrew Morton wrote:
> Christoph Hellwig <hch@infradead.org> wrote:
> >
> > > Hi Linus, Andrew,
> >  > 
> >  > The attached patch adds syscalls for almost all archs (everything barring
> >  > m68knommu which is in a real mess, and i386 which already has it).
> >  > 
> >  > It also adds 32->64 compatibility where appropriate.
> > 
> >  Umm, that patch added the damn multiplexer that had been vetoed multiple
> >  times.  Why did this happen?
> 
> Fifteen new syscalls was judged excessive and the keyfs interface was
> judged slow and bloaty.

Maybe 15 syscalls just means the API is goddamn awfull and we certainly
shouldn't merge it as-is.

