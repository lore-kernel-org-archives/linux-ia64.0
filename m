From: Jeff Law <law@redhat.com>
Date: Wed, 01 Feb 2012 18:45:57 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <4F298865.5000409@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CA+55aFxmdskUXX1iBaPx7rUGD95UqNJxhe1BLeVtZjqHjBpsPA@mail.gmail.com>	<alpine.LRH.2.00.1202011808240.22725@twin.jikos.cz>	<Pine.LNX.4.64.1202011818570.25409@wotan.suse.de> <20120201.130905.1131458895704793597.davem@davemloft.net>
In-Reply-To: <20120201.130905.1131458895704793597.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: matz@suse.de, jkosina@suse.cz, torvalds@linux-foundation.org, walters@verbum.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On 02/01/2012 11:09 AM, David Miller wrote:
> From: Michael Matz<matz@suse.de>
> Date: Wed, 1 Feb 2012 18:41:05 +0100 (CET)
>
>> One problem is that it's not a new problem, GCC emitted similar code since
>> about forever, and still they turned up only now (well, probably because
>> ia64 is dead, but sparc64 should have similar problems).
>
> Indeed, on sparc64 it does do the silly 64-bit access too:
>
> wrong:
>          ldx     [%o0+8], %g2
>          sethi   %hi(2147483648), %g1
>          or      %g2, %g1, %g1
>          jmp     %o7+8
>           stx    %g1, [%o0+8]
>
> Personally I've avoided C bitfields like the plague in any code I've
> written.
Torvald Riegel & I were told that was kernel policy when we brought up 
the upcoming bitfield semantic changes with some of the linux kernel 
folks last year.

Regardless of the kernel team's policy WRT bitfields, I believe fixing 
the semantics to avoid creation of data races in bitfields is going to 
be important.  I'm hoping Aldy can return to that task soon and he and 
Richi can come to some agreement on the implementation with gcc-4.8 as a 
target.

jeff
