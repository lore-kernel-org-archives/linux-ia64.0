From: Jim Wilson <wilson@tuliptree.org>
Date: Sun, 24 Aug 2003 01:23:02 +0000
Subject: Re: cross compiling ia64!
Message-Id: <marc-linux-ia64-106168819600532@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106154319501965@msgid-missing>
In-Reply-To: <marc-linux-ia64-106154319501965@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2003-08-22 at 02:05, Ameya Mitragotri wrote:
> I have been trying ,rather unsuccessfully, to cross compile the linux
> kernel 2.6-test3 using the compiler inside the NUE 1.2.

NUE was useful when IPF hardware was hard to get, but that hasn't been a
problem for a long time.  As a result, NUE hasn't been updated in a
while, and has obsolete versions of tools.

> I get the following errors using gcc version 2.96-ia64-000717 snap
> 001117)

The 2.96-ia64-000717 release is ancient history now.  It shouldn't be
used anymore.

> Replaced the gcc with 3.0.1 & binutils with 2.11. The binutils still
> gave problems, replaced them with 2.14. This took care of the assembler

gcc-3.0.1 and binutils-2.11 are also both old tool versions. 
binutils-2.14 is the latest release and should be OK.  Gcc is at 3.3.1
now, but 3.2 is probably also usable.

> My guess that 3.0.1 may not be the correct version for compiling 2.6. I
> have also tried to compile 2.95.3 (as suggested in the README) for ia64,
> but it seem that 2.95.3 does not support ia64 configuration. Any
> pointers/references to solve this?

The IA-64 port was written after gcc-2.95 was released.  Anyone
recommending gcc-2.95 for IA-64 is confused.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com

