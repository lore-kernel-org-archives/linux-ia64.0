From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 23 Mar 2001 06:53:51 +0000
Subject: Re: [Linux-ia64] kernel update (second patch relative to 2.4.2)
Message-Id: <marc-linux-ia64-105590693005344@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005334@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005334@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Sounds reasonable.  But I hope you don't mind if I recommend against
>using gcc3 for the kernel until the things I mentioned get fixed.

Yes, that is OK, but I'm of mixed mind about it.  Half of me is happy that
I don't have to support gcc3.  But half of me is wondering that if you forced
use of gcc3, then perhaps everyone would be asking about the same kernel
miscompilation problem, instead of everyone asking about different problems
most of which aren't as important, but still have to be answered.

>Incidentally, I think you mentioned that someone is considering to
>implement the unwind api proposed by the C++ ABI.  Is the plan to use

Yes, Richard Henderson is working on it, and making good progress.  This
is one of the issues holding up the gcc3 release, as the gcc3 release manager
would like this patch to be in it.  For a recent report (yesterday), see
http://gcc.gnu.org/ml/gcc-patches/2001-03/msg01599.html
http://gcc.gnu.org/ml/gcc-patches/2001-03/msg01600.html
To be usable in gcc3, the unwinder has to work for all targets, and that
makes it time consuming to implement and debug.

This is just an API.  It dictates what functions the compiler is supposed
to call to implement unwinding.  It doesn't specify the implementation of
the unwinders.  For those, we are using all of the existing ones, the
setjmp/longjmp unwinder, the DWARF2 frame info unwinder, and the IA-64
unwind info unwinder.  I haven't examined the patches in great detail, but
I believe there is little change to the existing unwinders at this time.

I am not surprised to see C in the list.  Gcc is emitting unwind info by
default for all languages, because I think that is the right thing to do.
It did not do this in the beginning.  This means the -fexception-tables
(or whatever) option that the kernel is using isn't necessary once you
switch to gcc3.

Jim

