From: "David S. Miller" <davem@davemloft.net>
Date: Wed, 20 Oct 2004 22:01:49 +0000
Subject: Re: [PATCH] Add key management syscalls to non-i386 archs
Message-Id: <20041020150149.7be06d6d.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <3506.1098283455@redhat.com>
In-Reply-To: <3506.1098283455@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Howells <dhowells@redhat.com>
Cc: torvalds@osdl.org, akpm@osdl.org, linux-kernel@vger.kernel.org, discuss@x86-64.org, sparclinux@vger.kernel.org, linuxppc64-dev@ozlabs.org, linux-m68k@vger.kernel.org, linux-sh@m17n.org, linux-arm-kernel@lists.arm.linux.org.uk, parisc-linux@parisc-linux.org, linux-ia64@vger.kernel.org, linux-390@vm.marist.edu, linux-mips@linux-mips.org


David, I applaud your effort to take care of this.
However, this patch will conflict with what I've
sent into Linus already for Sparc.  I also had to
add the sys_altroot syscall entry as well.

I've mentioned several times that perhaps the best
way to deal with this problem is to purposefully
break the build of platforms when new system calls
are added.

Simply adding a:

#error new syscall entries for X and Y needed

to include/asm-*/unistd.h would handle this just
fine I think.

That way it won't be missed, and if the platform
maintainer wants to just ignore the new syscall
they can choose to do that as well.
