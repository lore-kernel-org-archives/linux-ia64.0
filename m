From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 30 Jan 2002 22:20:31 +0000
Subject: Re: [Linux-ia64] Pseudo-ops: IAS versus ia64-hp-linux-as
Message-Id: <marc-linux-ia64-105590698805967@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805959@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805959@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>  Does the ia64-hp-linux-as assembler which comes with the
> Ski/NUE support all pseudo-ops as done by the 
> Intel Assembler IAS , [ as given in the Assembler Users Guide]
> ?

GNU as follows the assembler and architecture documentation.  There are
some differences in syntax from IAS because IAS doesn't always follow the
documentation.  No one has really tried to figure out whether IAS or the
docs are wrong, we just follow the docs.  There are only a couple of
minor differences though which are easy to work around.

GNU as supports all of the pseudo-ops, and most of the directives.  I don't
know of anyone who has tried to verify this, so there could be some obscure
ones missing.  Some of the optional directives are deliberately not
immplemented.  These are mostly the directives for performing register
allocation in the assembler.  GNU as doesn't do register allocation, nor
do we think it should.  Also, .org is not implemented since GNU ld can't
support it.

> The Guide is unclear about what the ld8.mov instruction
> does. Can somebody explain this to me ?

There is ld8.mov instruction.  Perhaps you mean ld8.fill?  See the Software
Developers Manual, which explains what every instruction does.  See also
the explanation of the register stack engine and NaT bits, which us what
ld8.fill is used for.

Jim


