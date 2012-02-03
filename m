From: Matthew Gretton-Dann <matthew.gretton-dann@arm.com>
Date: Fri, 03 Feb 2012 10:03:31 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <20120203100331.GB2544@e103070-lin.arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
 <xnbopg8lex.fsf@greed.delorie.com>
 <alpine.LNX.2.00.1202031034450.4999@zhemvz.fhfr.qr>
In-Reply-To: <alpine.LNX.2.00.1202031034450.4999@zhemvz.fhfr.qr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Richard Guenther <rguenther@suse.de>
Cc: DJ Delorie <dj@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "dsterba@suse.cz" <dsterba@suse.cz>, "ptesarik@suse.cz" <ptesarik@suse.cz>, "gcc@gcc.gnu.org" <gcc@gcc.gnu.org>

On Fri, Feb 03, 2012 at 09:37:22AM +0000, Richard Guenther wrote:
> On Fri, 3 Feb 2012, DJ Delorie wrote:
> 
> > 
> > Jan Kara <jack@suse.cz> writes:
> > >   we've spotted the following mismatch between what kernel folks expect
> > > from a compiler and what GCC really does, resulting in memory corruption on
> > > some architectures. Consider the following structure:
> > > struct x {
> > >     long a;
> > >     unsigned int b1;
> > >     unsigned int b2:1;
> > > };
> > 
> > If this structure were volatile, you could try
> > -fstrict-volatile-bitfields, which forces GCC to use the C type to
> > define the access width, instead of doing whatever it thinks is optimal.
> > 
> > Note: that flag is enabled by default for some targets already, most
> > notably ARM.
> 
> Note that -fstrict-volatile-bitfields does not work for
> 
> volatile struct S {
>     int i : 1;
>     char c;
> } s;
> int main()
> {
>   s.i = 1;
>   s.c = 2;
> }
> 
> where it accesses s.i using SImode.  -fstrict-volatile-bitfields
> falls foul of all the games bitfield layout plays and the
> irrelevantness of the declared bitfield type (but maybe the
> ARM ABI exactly specifies it that way).

Indeed the ARM ABI does - see Section 7.1.7.5 of the PCS available at:

http://infocenter.arm.com/help/topic/com.arm.doc.ihi0042-/

In fact the example above is pretty much the same as that given in the ABI
docs, and it says that accessing s.i will also cause an access
to s.c, but not vice-versa.

Thanks,

Matt

-- 
Matthew Gretton-Dann
Principal Engineer, PD Software, ARM Ltd.

