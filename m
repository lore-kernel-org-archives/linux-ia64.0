From: Gerrit Huizenga <gerrit@us.ibm.com>
Date: Mon, 13 Nov 2000 22:25:36 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels test10 and upper?
Message-Id: <marc-linux-ia64-105590678205703@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've built Jim's 1024 toolchain release this way.

I have not yet played with the test10 kernel - I'm still on test9 because
of the number of patches I'm using, not all of which are yet at test10
(actually, the last one or two was just announced, so I can probably move
up a notch soon).

You might want to look into just why it won't boot.  There are several
workarounds (e.g. qlc > 4GB memory addressing turned on in BIOS, EFI
workarounds, kernel config parameters such as VHPT and related workarounds
enabled/disabled, etc.).  Your problem may not be just the toolchain.

gerrit

> >I was able to build this toolchain (the lack of pre-existing g++ stuff
> >on my IA64 machine was a small problem but I ignored it for the time
> >being).  I installed it into a /usr/gcc1024 hierarchy so as not to
> >clobber my existing gcc (since I'm not yet moving to glibc 2.2 on
> >that machine).
> 
> Which toolchain are you building?
> 
> >Then I could build the kernel (on a Red Hat Linux release 6.93 (Zoot))
> >release, cut sometime in June, I believe.
> >
> >Then, I built the kernel with:
> >
> >HOSTCC=/usr/bin/gcc CC=/usr/gcc1024/bin/gcc make HOSTCC=/usr/bin/gcc
> >CC=/usr/gcc1024/bin/gcc -j 20 > ERRS 2>&1 &
> >
> >Which seems to work reasonably well.  This allows the cross tools to
> >build with the native CC (glibc 2.1 based) and the kernel to build
> >with a recent compiler, which does not care a whit about glibc
> >support.
> >
> >The native toolchain on that Red Hat distro does not have unwind
> >support, impylying no stack tracebacks in panics, kdb, etc.  The newer
> >gcc works fine, compiles completely, and has wonderful stack
> >tracebacks.
> >
> >All this on a 4-proc Lion, running A3 procs and an ancient BIOS/frame
> >(my B2/B3 upgrade has been deferred for a while).
> 
> I'm trying to build the 2.4.0-test10 kernel with the ia64 patch.  We
> recently upgaded the hardware on one of our boxes to B1 stepping, and
> now it won't boot.  I'm hoping the newer kernel will work better.
> 
> So far, I'm running into problems with the old Red Hat toolchain, and
> with the latest snapshot as well.  I haven't hit on the right compiler
> yet, I guess.
> 
> Has anyone successfully built 2.4.0-test10 with the IA64 patch?  If so,
> which toolchain did you use?
> 
> - Scott
> 
> -----------------------------
> Scott Hankin                  In the beginning, there was nothing, then
> Rational Software             God said, "Let there be light."  And there
> 20 Maguire Road               was light.  There was still nothing, but
> Lexington, MA 02421           you could see it a lot better.
> 

