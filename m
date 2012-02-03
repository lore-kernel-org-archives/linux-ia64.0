From: Richard Guenther <rguenther@suse.de>
Date: Fri, 03 Feb 2012 09:37:22 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <alpine.LNX.2.00.1202031034450.4999@zhemvz.fhfr.qr>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <xnbopg8lex.fsf@greed.delorie.com>
In-Reply-To: <xnbopg8lex.fsf@greed.delorie.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: DJ Delorie <dj@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, dsterba@suse.cz, ptesarik@suse.cz, gcc@gcc.gnu.org

On Fri, 3 Feb 2012, DJ Delorie wrote:

> 
> Jan Kara <jack@suse.cz> writes:
> >   we've spotted the following mismatch between what kernel folks expect
> > from a compiler and what GCC really does, resulting in memory corruption on
> > some architectures. Consider the following structure:
> > struct x {
> >     long a;
> >     unsigned int b1;
> >     unsigned int b2:1;
> > };
> 
> If this structure were volatile, you could try
> -fstrict-volatile-bitfields, which forces GCC to use the C type to
> define the access width, instead of doing whatever it thinks is optimal.
> 
> Note: that flag is enabled by default for some targets already, most
> notably ARM.

Note that -fstrict-volatile-bitfields does not work for

volatile struct S {
    int i : 1;
    char c;
} s;
int main()
{
  s.i = 1;
  s.c = 2;
}

where it accesses s.i using SImode.  -fstrict-volatile-bitfields
falls foul of all the games bitfield layout plays and the
irrelevantness of the declared bitfield type (but maybe the
ARM ABI exactly specifies it that way).

So no, I would not recommend -fstrict-volatile-bitfields.

Richard.
