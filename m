From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 26 Oct 2000 18:14:13 +0000
Subject: Re: [Linux-ia64] Working gcc for IA64 with unwind support
Message-Id: <marc-linux-ia64-105590678205636@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205631@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205631@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>The CVS gcc has broken cross compile ix86->IA64,

All cross compilers from 32-bit hosts to 64-bit targets have been broken since
about March.  I've posted about it a few times, but as yet no one has
volunteered to fix the problem.  Cygnus, err Red Hat, has some hacks that make
it work, but no one has tried to turn this into a real patch yet.  This means
it does work in the Cygnus/Red Hat releases.  I've been busy fixing IA-64
specific problems, so I haven't had much time to work on generic gcc problems
like this.

>incorrect optimization (bug C/645)

I didn't know there was an IA-64 specific gcc bug report in the FSF GNATS
database.  I took a look.

It is an assembler bug.  I believe this was fixed a month or two ago in the
assembler.  If you are using current CVS gcc, you must use current CVS
binutils, and you also need to use glibc 2.2 or apply patches to revert ABI
changes.

>spurious warning messages

What kind of messages?  Eventually these should all go away, but the compiler
isn't finished yet, so there are some that we have to live with for now.
I'm fixing them as fast as I can.  If anyone wants to volunteer to help,
it would be appreciated.  There is probably a lot more toolchain work that
needs to be done than there is kernel work to do.

>no crt1 etc.

The crt1 file comes from glibc, not from gcc.

>After working
>around the gcc problems, the resulting kernel will not boot, it breaks
>during efi time initialization.

FSF Gcc development is rather chaotic, so it isn't unusal to find that any
particular snapshot is broken.  These are mostly not IA-64 bugs, so it is a
waste of time to try to fix them all immediately.

I'd suggest using the stable gcc branch that I maintain for the ia64-linux
group instead of the top of the FSF gcc tree.  This can be found at
ftp.cygnus.com in pub/ia64-linux.  This is intended for glibc 2.2, but I have
a patch that makes it work reasonably well on glibc-2.1.3 systems.

>Does anybody have a working toolchain for IA64 that supports the latest
>unwind descriptors?  Preferably one that actually cross compiles from
>ix86.

The current stable toolchain satisfies these criteria.

Jim

