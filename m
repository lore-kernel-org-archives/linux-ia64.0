From: Torvald Riegel <triegel@redhat.com>
Date: Wed, 01 Feb 2012 17:08:57 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <1328116137.15992.6146.camel@triegel.csb>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
In-Reply-To: <20120201151918.GC16714@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, 2012-02-01 at 16:19 +0100, Jan Kara wrote:
> I've raised the issue with our GCC guys and they said to me that: "C does
> not provide such guarantee, nor can you reliably lock different
> structure fields with different locks if they share naturally aligned
> word-size memory regions.  The C++11 memory model would guarantee this,
> but that's not implemented nor do you build the kernel with a C++11
> compiler."

Indeed, it's memory models that specify which kind of behavior is
allowed, and you need them for both the hardware and the programming
language.  C++11 and C11 have memory models, in contrast to previous
versions of these standards.
GCC 4.7 implements this memory model (C++11's and C11's models are very
similar), even though there might be some rough edges in this
implementation (bit fields, for example...).
http://gcc.gnu.org/wiki/Atomic/GCCMM

> So it seems what C/GCC promises does not quite match with what kernel
> expects. I'm not really an expert in this area so I wanted to report it
> here so that more knowledgeable people can decide how to solve the issue...

There needs to be agreement about the memory model.  The only time I
spoke to a kernel person about memory models, I got the reply that the
kernel would use its own model.

What do the kernel folks think about the C11 memory model?  If you can
spot any issues in there, the GCC community would certainly like to
know.


Torvald

