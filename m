From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 29 Jan 2003 06:07:52 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.59)
Message-Id: <marc-linux-ia64-105590709805765@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 29 Jan 2003 15:27:26 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:
  David> Oh, most importantly: you'll need a new assembler in order to
  David> use this patch.  There was a nasty bug up until Dec 18 last
  David> year which basically made certain place-relative expressions
  David> generate bad data.  Fortunately, HJ Lu has fixed that bug and
  David> I put a read-for-use, static binary of a fixed assembler at:

  David> ftp://ftp.hpl.hp.com/pub/linux-ia64/gas-030124.tar.gz

  David> As a measure of safety, I added a sanity check which will
  David> cause "make" to refuse to build a kernel with a buggy
  David> assembler.

  Peter> The sanity check doesn't work under nue --- I guess that the
  Peter> compiler/assembler there is too old.

  Peter> I see: check-gas-asm.S: Assembler messages:
  Peter> check-gas-asm.S:1: Error: Expected ':' check-gas-asm.S:1:
  Peter> Error: Rest of line ignored. First ignored character is ':'.
  Peter> check-has-asm.S:2: Error: backw. ref to unknown label "1:", 0
  Peter> assumed.  objdump: check-gas-asm.o: No such file or directory
  Peter> check-gas: [: !=: unary operator expected

  Peter> (And then check-gas script echoes 'good' and things go
  Peter> on... even though it's not good)

But even if the sanity-check worked, it would only tell you that your
assembler is too old.

  Peter> Is there going to be a new nue available soon, with a later
  Peter> toolchain?

I'd like to update the Ski simulator soon, but we don't have any plans
for updating NUE.  Since NUE is all based on open source, anyone can
do that (and frankly, I just don't need/use NUE myself anymore; in
constrast to Ski, which is still very useful for low-level work).

	--david

