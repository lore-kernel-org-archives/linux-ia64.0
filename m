From: "McCaffity, Ray" <ray.mccaffity@wcg.com>
Date: Tue, 01 May 2001 19:47:46 +0000
Subject: RE: [Linux-ia64] New Red Hat Linux Beta release for ia64 availabl
Message-Id: <marc-linux-ia64-105590693005505@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205864@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205864@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just a lot of little questions here, not really directed at anyone in
particular.

1. I know with all the hub-bub surrounding BogoMips the last few years on
the x86
   platforms, the number doesn't mean a whole lot.  But I still use it as a
"close-enough"
   baseline for some of my servers.  Anyway, the output from cat
/proc/cpuinfo is
   slightly different from the bogoMips in the dmesg.  Which one is more
reliable?

2. For my 733Mhz IA64's, my BogoMips is around 730, which is slower than 1
bogo per
   MHz.  This is a long way from what I get with x86 processors.  Perhaps
it's mostly
   because I haven't been able to optimize my kernel yet, (typically my x86
kernels will
   fit on a floppy pretty easily after recompiling, and then my benchmarks
are sometimes
   as much as 50% faster depending on what I'm trying to do)
         I am finally able to download the new redhat/wolverine as I'm
typing this.
   Hopefully I'll have better luck compiling it.

3. If the strength of the IA64 isn't really speed, I suspect it's power is
in the
   number of multiple threads?  For example, on some of my Solaris servers I
run
   apache bench against a certain file (single URL).  But I can't have more
than
   256 connections to that single file without making some changes to kernel
parameters,
   if I go too far the server starts getting unstable.  What are the number
of
   file handles supported by Linux 2.4.x ?  Is is different for IA64?  I
have been
   able to run over 1000 concurrent connections on my IA64 server and it
doesn't seem
   to slow it down much.

4. I know everything we are talking about here is beta, but another area I
have problems
   with is 32-bit emulation.  I have seen questions about Oracle and JAVA
for IA64 Linux
   on other threads, and who knows when they'll happen.  Has anyone had much
luck trying
   to get these to run under Linux-IA64?

Not really meaning to take up peoples important time with trivial questions.
But
some of this affects plans our IT dept has over the 6 months to a year.

Ray

