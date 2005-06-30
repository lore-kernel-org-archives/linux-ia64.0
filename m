From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 30 Jun 2005 14:15:36 +0000
Subject: Re: Fast Syscalls and Virtualised Linux on Linux
Message-Id: <20050630141536.GA27256@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <17090.8605.481641.322881@wombat.chubb.wattle.id.au>
In-Reply-To: <17090.8605.481641.322881@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 29, 2005 at 02:20:45PM +1000, Peter Chubb wrote:
> One approach might be to redefine __BREAK_SYSCALL for the guest OS.
> That'd require a specially compiled glibc and kernel, and possibly
> other executables.
> 
> Does anyone have a better idea?

Make sure glibc is always doing syscalls via the vdso (and that the kernel
actually support this ;-)) Then the guest kernel can provide an alternate
vdso implementation using whatever implementation it wants.  This also
allows the kernel an chose different syscall implemetations for native
compilation later on.  x86 is already doing this to suport sysenter()

