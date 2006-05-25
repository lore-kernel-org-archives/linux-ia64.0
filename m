From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 25 May 2006 00:05:50 +0000
Subject: Re: dropping CONFIG_IA32_SUPPORT from ia64
Message-Id: <20060525000550.GB12150@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200605241438.34303.bjorn.helgaas@hp.com>
In-Reply-To: <200605241438.34303.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, May 24, 2006 at 02:23:18PM -0700, Luck, Tony wrote:
> > It doesn't feel right to me to remove functionality from machines
> > in the field and offer only a proprietary alternative.
> 
> The alternative to dropping support for CONFIG_IA32_SUPPORT is
> to find someone to maintain it ... right now it doesn't get much
> of my time, so it is a ticking quagmire of untested code.

A twist on that theme is to merge the parts of ia32 emulation in the
ia64 kernel with the x86_64 architecture.  Where that makes sense,
anyway.  Large portions of the ia32 emulation are already common with
other CONFIG_COMPAT architectures, so reducing the amount of code
reduces the amount of potentially buggy code ;-)

A first step on that road would be to create one syscall table for
i386/ia32 emulation.  Take a look at arch/parisc/kernel/syscall_table.S
for one approach to this.  The interesting part to this is that some
syscalls seem to require different treatment on ia64 and x86_64 (last
time I looked at doing this anyway).  That can be handled with some
additional ENTRY_ types.

I've been meaning to get round to this for a while, but somehow I never
quite have time.
