From: Richard Guenther <rguenther@suse.de>
Date: Thu, 02 Feb 2012 11:24:33 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <alpine.LNX.2.00.1202021223460.4999@zhemvz.fhfr.qr>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="8323584-1749499345-1328181873=:4999"
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <CAAMvbhEc8E39PCCoT1CyjUqSyph18FmPnaJYc7B3ZazYgUu2GQ@mail.gmail.com>
In-Reply-To: <CAAMvbhEc8E39PCCoT1CyjUqSyph18FmPnaJYc7B3ZazYgUu2GQ@mail.gmail.com>
To: James Courtier-Dutton <james.dutton@gmail.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, dsterba@suse.cz, ptesarik@suse.cz, gcc@gcc.gnu.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1749499345-1328181873=:4999
Content-Type: TEXT/PLAIN; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Thu, 2 Feb 2012, James Courtier-Dutton wrote:

> On 1 February 2012 15:19, Jan Kara <jack@suse.cz> wrote:
> >  Hello,
> >
> >  we've spotted the following mismatch between what kernel folks expect
> > from a compiler and what GCC really does, resulting in memory corruption on
> > some architectures. Consider the following structure:
> > struct x {
> >    long a;
> >    unsigned int b1;
> >    unsigned int b2:1;
> > };
> >
> > We have two processes P1 and P2 where P1 updates field b1 and P2 updates
> > bitfield b2. The code GCC generates for b2 = 1 e.g. on ia64 is:
> >   0:   09 00 21 40 00 21       [MMI]       adds r32=8,r32
> >   6:   00 00 00 02 00 e0                   nop.m 0x0
> >   c:   11 00 00 90                         mov r15=1;;
> >  10:   0b 70 00 40 18 10       [MMI]       ld8 r14=[r32];;
> >  16:   00 00 00 02 00 c0                   nop.m 0x0
> >  1c:   f1 70 c0 47                         dep r14=r15,r14,32,1;;
> >  20:   11 00 38 40 98 11       [MIB]       st8 [r32]=r14
> >  26:   00 00 00 02 00 80                   nop.i 0x0
> >  2c:   08 00 84 00                         br.ret.sptk.many b0;;
> >
> > Note that gcc used 64-bit read-modify-write cycle to update b2. Thus if P1
> > races with P2, update of b1 can get lost. BTW: I've just checked on x86_64
> > and there GCC uses 8-bit bitop to modify the bitfield.
> >
> > We actually spotted this race in practice in btrfs on structure
> > fs/btrfs/ctree.h:struct btrfs_block_rsv where spinlock content got
> > corrupted due to update of following bitfield and there seem to be other
> > places in kernel where this could happen.
> >
> > I've raised the issue with our GCC guys and they said to me that: "C does
> > not provide such guarantee, nor can you reliably lock different
> > structure fields with different locks if they share naturally aligned
> > word-size memory regions.  The C++11 memory model would guarantee this,
> > but that's not implemented nor do you build the kernel with a C++11
> > compiler."
> >
> > So it seems what C/GCC promises does not quite match with what kernel
> > expects. I'm not really an expert in this area so I wanted to report it
> > here so that more knowledgeable people can decide how to solve the issue...
> 
> What is the recommended work around for this problem?

The recommended work around is to re-layout your structures.

Richard.
--8323584-1749499345-1328181873=:4999--
