From: Matthew Wilcox <willy@debian.org>
Date: Thu, 09 Oct 2003 00:21:48 +0000
Subject: Re: [PATCH] Fix IA64 build with separate source and build trees.
Message-Id: <marc-linux-ia64-106565897210783@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106565735409518@msgid-missing>
In-Reply-To: <marc-linux-ia64-106565735409518@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 09, 2003 at 09:52:12AM +1000, Peter Chubb wrote:
> Hi David,
>    This patch against 2.6.0-test7 fixes building in a separate output
> directory.  Without it, offsets.h isn't built, and the check-gas and
> toolchain-flags sscripts aren't found.

I'm more curious than anything ...

> +arch/$(ARCH)/kernel/asm-offsets.s: include/asm include/linux/version.h
[...]
> -arch/ia64/kernel/asm-offsets.s: include/asm-ia64/.offsets.h.stamp
> +arch/ia64/kernel/asm-offsets.s: include/asm-$(ARCH)/.offsets.h.stamp

What's the advantage to using $(ARCH) here?  Since this is in an arch
directory, we already know our $ARCH.  And if we are going to use it,
shouldn't it be used everywhere?

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
