From: "Saxena, Sunil" <sunil.saxena@intel.com>
Date: Wed, 26 Apr 2000 20:58:15 +0000
Subject: RE: [Linux-ia64] ld failure
Message-Id: <marc-linux-ia64-105590678205055@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205047@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205047@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jim,

Here are the relocations that have been agreed in the ABI.  You can talk to
Ulrich on details:

Name         Value     Instruction Format     Expression
------------------------------------------------------------------
PCREL60B     0x48      br long (X3, X4)       symbol + addend - IP
PCREL21BI    0x79      br (B1, B2, B3, B6)    symbol + addend - IP
PCREL22      0x7A      add imm22 (A5)         symbol + addend - IP
PCREL64I     0x7B      mov imm64 (I18/X2)     symbol + addend - IP

The PCREL21BI relocation works just like PCREL21B, but it marks a call for
which gp has not been saved, thus requiring that the target reside within
the same load module as the call. We need it for cases where we choose to
bind a symbol locally, optimizing the call sequence, but where we don't want
to, or can't, mark the symbol "protected" or "hidden."

The PCREL22 and PCREL64I relocations are needed for pc-relative references
to constants and literals. PCREL64I is also needed (internally to the
linker) for long branch stubs.

Regarding the brl emulation, we should have a patch ready for Trillian work
next week.

Thanks
Sunil

-----Original Message-----
From: Jim Wilson [mailto:wilson@cygnus.com]
Sent: Wednesday, April 26, 2000 11:58 AM
To: Christoph Rohland
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] ld failure 


There is an optional patch available for the current stable toolchain that
fixes this.  There are a few details to work out.
1) It uses the linker relaxation support, which isn't the default.  So for
   the moment the user needs to manually specify -Wl,-relax on the gcc
command
   line.
2) It uses the brl instruction which the Itanium does not implement.  The
   kernel needs to emulate the instruction.  I know that people are working
on
   this kernel support, but I don't know if it is available yet.  So you
will
   be able to link the program, but you may not be able to run it.
3) The ABI does not define relocations for brl yet, so we invented our own.
   These will have to change when standard relocations are specified, which
   may result in a user visble ABI change.

These problems should hopefully all be resolved by the time of the next
toolchain release, which is tentatively scheduled for late June.

Looking at this, I see that some rearrangement of code in our startup files
might help delay the point at which a program becomes too big.  I'll make a
note to myself to look into that.



