From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 21 Oct 2004 01:55:32 +0000
Subject: Re: [discuss] Re: [PATCH] Add key management syscalls to non-i386
Message-Id: <1098323732.20955.31.camel@gaston>
List-Id: <linux-ia64.vger.kernel.org>
References: <3506.1098283455@redhat.com>
	 <20041020150149.7be06d6d.davem@davemloft.net>
	 <20041020225625.GD995@wotan.suse.de>
	 <20041020160450.0914270b.davem@davemloft.net>
In-Reply-To: <20041020160450.0914270b.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>, discuss@x86-64.org, linux-m68k@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-sh@m17n.org, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-390@vm.marist.edu, Linus Torvalds <torvalds@osdl.org>, sparclinux@vger.kernel.org, linuxppc64-dev <linuxppc64-dev@ozlabs.org>, linux-arm-kernel@lists.arm.linux.org.uk, parisc-linux@parisc-linux.org

On Thu, 2004-10-21 at 09:04, David S. Miller wrote:
> On Thu, 21 Oct 2004 00:56:25 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > I don't think that's a good idea.  Normally new system calls 
> > are relatively obscure and the system works fine without them,
> > so urgent action is not needed.
> > 
> > And I think we can trust architecture maintainers to regularly
> > sync the system calls with i386.
> 
> I disagree quite strongly.  One major frustration for users of
> non-x86 platforms is that functionality is often missing for some
> time that we can make trivial to keep in sync.

I agree with David here. It's also easy for arch/platform maintainers to
"miss" a new syscall too ... for various reasons, we can't all read
_everything_ that gets posted to lkml and we all do occasionally miss
some csets going upstream, which means we can very well totally "forget"
about addint the new syscall to the arch ... until somebody complains,
which can be 1 or 2 releases later !

> I religiously watch what goes into Linus's tree for this purpose,
> but that is kind of a rediculious burdon to expect every platform
> maintainer to do.  It's not just system calls, we have signal handling
> bug fixes, trap handling infrastructure, and now the nice generic
> IRQ handling subsystem as other examples.

Right.

> Simply put, if you're not watching the tree in painstaking detail
> every day, you miss all of these enhancements.
>
> The knowledge should come from the person putting the changes into
> the tree, therefore it gets done once and this makes it so that
> the other platform maintainers will find out about it automatically
> next time they update their tree.

Agreed,
Ben.

