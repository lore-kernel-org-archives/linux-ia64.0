From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 29 Jan 2003 04:27:26 +0000
Subject: [Linux-ia64] kernel update (relative to 2.5.59)
Message-Id: <marc-linux-ia64-105590709805764@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:


David> Oh, most importantly: you'll need a new assembler in order to
David> use this patch.  There was a nasty bug up until Dec 18 last
David> year which basically made certain place-relative expressions
David> generate bad data.  Fortunately, HJ Lu has fixed that bug and I
David> put a read-for-use, static binary of a fixed assembler at:

David> 	ftp://ftp.hpl.hp.com/pub/linux-ia64/gas-030124.tar.gz

David> As a measure of safety, I added a sanity check which will cause
David> "make" to refuse to build a kernel with a buggy assembler.

The sanity check doesn't work under nue --- I guess that the
compiler/assembler there is too old.

I see:
check-gas-asm.S: Assembler messages:
check-gas-asm.S:1: Error: Expected ':'
check-gas-asm.S:1: Error: Rest of line ignored. First ignored
character is ':'.
check-has-asm.S:2: Error: backw. ref to unknown label "1:", 0 assumed.
objdump: check-gas-asm.o: No such file or directory
check-gas: [: !=: unary operator expected

(And then check-gas script echoes 'good' and things go on... even
though it's not good)

Is there going to be a new nue available soon, with a later toolchain?

Peter C

