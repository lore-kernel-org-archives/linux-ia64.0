From: Christoph Hellwig <hch@ns.caldera.de>
Date: Tue, 18 Sep 2001 16:57:15 +0000
Subject: Re: [Linux-ia64] Re: PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805212@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805199@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805199@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 18, 2001 at 09:33:11AM -0700, David Mosberger wrote:
> I think LSB is correct in suggesting /libXX for the native code model
> and "something" else for emulated code models.  /opt/emu32 is clearly
> a silly name though: it mixes up the data model and the code model
> again.  For the IA-64 Linux project, we're currently using
> /emul/ia32-linux for the IA-32 subsystem.  (If there is strong
> objection and good reasons to reject the "/emul" prefix, I suppose we
> could use /opt/emu/ia32-linux/ instead.)

Don't put it in /opt.  For something like a binray emulator /opt
is just silly.

Currently mips and sparc use /usr/gnemul/<opsys>, Linux-ABI for ix86
uses /emul/<opsys>.  I'd suggest going for one of those, possibly
the latter (:)).

> A related question is whether /emul/ is reserved for "same OS"
> emulation.  E.g., where would a Windows emulator go?  If /emul/ only
> ever contains Linux emulators, then we could change the prefix to
> /emul/ia32/ but, from a user perspective, I think it would be
> preferable if /emul/ were allowed to contain foreign OS emulators as
> well.

It does.  On Linux-ABI I use e.g. /emul/osr5, /emul/uw7 and /emul/svr4.
Id suggest using /emul/<opsys> for emulations of another operating
system for the same architecture, /emul/<arch>-<opsys> for non-native.

Windows should go into /emul/win64 and /emul/ia32-win32.

	Christoph

-- 
Whip me.  Beat me.  Make me maintain AIX.

