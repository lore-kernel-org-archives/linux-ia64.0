From: Andreas Jaeger <aj@suse.de>
Date: Tue, 18 Sep 2001 17:50:52 +0000
Subject: Re: [Linux-ia64] Re: PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805214@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805199@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805199@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger <davidm@hpl.hp.com> writes:

>>>>>> On Tue, 18 Sep 2001 10:34:50 +0200, Andreas Jaeger <aj@suse.de> said:
>
>   Andreas> George, you forgot to add the appended part.  Especially
>   Andreas> the paragraph is important that this will not imply a
>   Andreas> binary incompatible change for ia64, ia64 has an emulation
>   Andreas> for 32-bit binaries but is not a real 32/64-bit platform
>   Andreas> like Sparc64, x86-64, PPC64 and S390.
>
>   Andreas> David, does this satisfy your ia64 concerns?
>
> To be honest, I think the description is confusing and incomplete.
> This is because it doesn't clearly distinguish between code model and
> data model.  On ia64, there are presently two code models (x86 and
> ia64) and two data models (ILP32 and LP64).  It turns out that three
> of the four resulting possibilities make sense:
>
>   (1) ia64/ilp32
>   (2) ia64/lp64
>   (3) x86/ilp32
>
> In the future, there could be others.  For example, I'm pretty sure
> that Alpha->ia64 binary translators are in the process of being
> written and on a Compaq system, it could make sense to have
> "alpha/lp64", for example.

Then we should discuss where those will end.  For ia64, the places are
according to the proposal:
(1) not defined
(2) /lib and /usr/lib
(3) not defind - but not /lib



> I think LSB is correct in suggesting /libXX for the native code model
> and "something" else for emulated code models.  /opt/emu32 is clearly
> a silly name though: it mixes up the data model and the code model
> again.  For the IA-64 Linux project, we're currently using
> /emul/ia32-linux for the IA-32 subsystem.  (If there is strong
> objection and good reasons to reject the "/emul" prefix, I suppose we
> could use /opt/emu/ia32-linux/ instead.)
>
> A related question is whether /emul/ is reserved for "same OS"
> emulation.  E.g., where would a Windows emulator go?  If /emul/ only
> ever contains Linux emulators, then we could change the prefix to
> /emul/ia32/ but, from a user perspective, I think it would be
> preferable if /emul/ were allowed to contain foreign OS emulators as
> well.
>
> Now, as far as /libXX is concerned: in my opinion, /lib should contain
> the "native" or "preferred" library format (primarily for source
> compatibility and user convenience reasons).  LSB is in denial if it
> claims /lib is used for 32-bit libraries only.  Both IA-64 and Alpha
> use it for 64-bit libraries and if, god forbid, someone ever added
> ILP32 support to IA-64 Linux, those libraries would certainly go into
> /lib32 or something of that sort.  LSB should consider and accommodate
> this case.

The proposal should just do this - and defines the "preferred" library
format.  For both ia64 and Alpha, it's 64-bit but for PPC64, Sparc64
etc it's 32-bit.

Andreas
-- 
 Andreas Jaeger
  SuSE Labs aj@suse.de
   private aj@arthur.inka.de
    http://www.suse.de/~aj

