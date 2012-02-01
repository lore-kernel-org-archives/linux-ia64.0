From: Jakub Jelinek <jakub@redhat.com>
Date: Wed, 01 Feb 2012 19:40:25 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <20120201194025.GG6148@sunsite.ms.mff.cuni.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
 <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
 <1328118174.15992.6206.camel@triegel.csb>
In-Reply-To: <1328118174.15992.6206.camel@triegel.csb>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Torvald Riegel <triegel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, Feb 01, 2012 at 06:42:54PM +0100, Torvald Riegel wrote:
> We need a proper memory model.  No vague assumptions with lots of
> hand-waving.  If you think that this is simple stuff and can
> sufficiently described by "don't do anything stupid", then please have a
> look at the issues that the Java memory model faced, and all the
> iterations of the C++11/C11 model and discussions about it.
> 
> The only candidate that I see is the C++11/C11 model.  Any other
> suggestions?

Well, the C++11/C11 model doesn't allow to use the underlying type
for accesses, consider e.g.

struct S { long s1; unsigned int s2 : 5; unsigned int s3 : 19; unsigned char s4; unsigned int s5; };
struct T { long s1 : 16; unsigned int s2; };

on e.g. x86_64-linux, S is 16 byte long, field s4 is packed together into
the same 32 bits as s2 and s3.  While the memory model allows s2 to be
changed when storing s3 (i.e. use a RMW cycle on it), it doesn't allow s4
to be changed, as it isn't a bitfield (you'd need s4 : 8 for that).
T is 8 bytes long, again, s2 is packed into the same 64 bits as s1,
and the memory model doesn't allow s2 to be modified.

Not sure what the kernel would expect in such a case.

	Jakub
