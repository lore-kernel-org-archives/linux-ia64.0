From: David Howells <dhowells@redhat.com>
Date: Wed, 20 Oct 2004 16:16:17 +0000
Subject: Re: [parisc-linux] [PATCH] Add key management syscalls to non-i386 archs
Message-Id: <7779.1098288977@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041020154922.GV16153@parcelfarce.linux.theplanet.co.uk>  <3506.1098283455@redhat.com> 
In-Reply-To: <20041020154922.GV16153@parcelfarce.linux.theplanet.co.uk> 
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: torvalds@osdl.org, akpm@osdl.org, discuss@x86-64.org, linux-m68k@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, linux-sh@m17n.org, linux-390@vm.marist.edu, sparclinux@vger.kernel.org, linuxppc64-dev@ozlabs.org, linux-arm-kernel@lists.arm.linux.org.uk, parisc-linux@parisc-linux.org


> Um, no.  Should be ENTRY_COMP() if there's compat syscalls.

Not all archs (of which PA-Risc is an example) seem to require the same fixups
on the same syscalls. In some instances, the upper half of the register is
implicitly zero on 32-bit syscall entry to a 64-bit kernel. In such cases,
none of my syscalls require fixing up, assuming the pointers are automatically
correct.

> And those particular syscall numbers have already been assigned (blame Linus
> for dropping the PA-RISC patch on the floor instead of including it in
> 2.6.9).

There's not a lot I can do about that, except wave a patch under Linus's nose
and see who complains. Can you allocate three syscall numbers for me for
parisc?

David
