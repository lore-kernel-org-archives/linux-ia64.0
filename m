From: Gerrit.Huizenga@us.ibm.com
Date: Wed, 23 Aug 2000 23:16:11 +0000
Subject: Re: [Linux-ia64] Memory clearing at reboot
Message-Id: <marc-linux-ia64-105590678205386@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205378@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205378@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Having an ability to dump system memory to disk from an application
> > other than the kernel that just crashed is a major serviceability
> 
> Patrick O'Rourke said...
>
> Do you mean the equivalent of 'dd if=/dev/mem of=<some file>?  The problem
> with dumping memory from an application is that the kernel is still active,

Not at all what I'm referring to - I mean instead it should be possible
for, say, an EFI app to read system memory after the kernel has
panic'd/shut down, and then copy that image to a disk for later kernel
or hardware fault isolation.  In larger sites and larger systems (where
Itanium will more likely fit in its first couple of years) customers
expect that the machine will be back in operation ASAP and the system
can not afford to be down while people run diagnostics or try things to
see if they can figure out what caused a kernel to crash.

On smaller systems, yes, debugging is also important; however, those
systems can be typically co-opted for HW or SW debugging.  The users
are more tolerant of someone saying "Oh, try that again" or "Here's
a debug kernel, see what happens".  A large database customer running
their business on a 16 processor machine is much less tolerant of
such impact to their systems.  Hence, being able to take a snapshot
of the machine state at the time of failure and sending that information
elsewhere for out of band debugging simplifies everyone's life.

Most operating systems tend to try to write an image to disk after the
system has failed.  As a result, a system with already corrupt memory
is trying to set up DMA or programmed IO of all of memory to some
disk subsystem, which tends to be a recipe for failure.  It's like
giving an accident victim the responsibility for self-diagnosis.

As far as which memory to dump, usually only kernel pages need to
be dumped; however, that takes a slightly more sophisticated dump
program and crash dump analyzer.  Not impossible, but usually not
a first generation choice (we've done exactly that with Sequent NUMA
systems several years back).

gerrit

