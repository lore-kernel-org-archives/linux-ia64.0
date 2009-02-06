From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 06 Feb 2009 16:12:29 +0000
Subject: Re: [linux-next][PATCH] revert headers_check fix: ia64, fpu.h
Message-Id: <20090206161229.GA8256@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090206164546.6291.KOSAKI.MOTOHIRO@jp.fujitsu.com> <3f9a31f40902060053x18dacf58u40c739ab89f13860@mail.gmail.com> <20090206180957.6294.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090206145556.GH18368@elte.hu> <1233934141.3209.20.camel@localhost.localdomain> <20090206153315.GD13758@n2100.arm.linux.org.uk> <1233935328.3209.30.camel@localhost.localdomain> <20090206155512.GF13758@n2100.arm.linux.org.uk>
In-Reply-To: <20090206155512.GF13758@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Jaswinder Singh Rajput <jaswinder@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jaswinder Singh Rajput <jaswinderlinux@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sam Ravnborg <sam@ravnborg.org>, Andrew Morton <akpm@linux-foundation.org>, hskinnemoen@atmel.com, cooloney@kernel.org, tony.luck@intel.com, ralf@linux-mips.org, dhowells@redhat.com, matthew@wil.cx, chris@zankel.net, LKML <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>


* Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:

> > We cannot see any downside of this patch.
> > 
> > But we can see upside of this patch is:
> > 1. No need to protect linux/types.h with #ifndef __ASSEMBLY__ in many
> > files
> > 2. So we trying to replace multiple #ifndef __ASSEMBLY__ with one.
> 
> The point is:
> 
> 1. If the parent include needs to include linux/types.h to get at C
>    types _and_ the include file needs to also be included by assembly
>    code, it itself needs to have #ifndef __ASSEMBLY__ to protect those
>    uses from the assembly code.
> 
>    In that case, the linux/types.h include should be contained within
>    the #ifndef __ASSEMBLY__ .. #endif block along with all C only
>    parts of the header file.

That makes the code much less clean: putting #include's in the middle of a 
header is poor style and leads to people failing to consider dependencies. 
We generally put them to the header portion.

Putting an #include line in the middle of a header file is a receipe for a 
dependency hell (it can easily fall inside #ifdefs, can be overlooked, 
etc.), so it's _strongly_ discouraged (at least on arch/x86).

> 2. if it doesn't need C types from linux/types.h, then that header has
>    no business including linux/types.h, and the include should be
>    eliminated to save the already dirbolically slow compiler from
>    having to read and parse that file, and more importantly allowing
>    it to eliminate linux/types.h from the build dependencies.
> 
> Yes, you can wrap linux/types.h with that ifndef, and yes it will fix any 
> problems, but I view it as a hack rather than fixing the real problem 
> which is lazyness by code writers to get their include dependencies right.

It is not about include dependencies at all - it is about the existing and 
accepted practice which you did not consider in your argument: the use of 
mixed-mode headers. A linux/types.h include there is perfectly clean and 
should not break the build.

Again, i repeat: there is nothing wrong about making a small number of very 
commonly used C header assembly-invariant. It results in better structured 
header files and cleaner code.

The argument is as simple as that, and up until this email you wrote roughly 
10 replies and it's not even that you disagreed with our point on some 
honest basis that we could argue with - the ting is that you failed to even 
_realize_ this argument of us and you tried to force your partial (and 
trivially flawed) world view on us impatiently. In view of that you need to 
be more careful before calling people 'stupidly obtuse' ;-)

	Ingo
