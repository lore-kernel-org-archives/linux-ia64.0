From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 01 Feb 2012 17:29:31 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <CA+55aFyG3EifFPapU6SFYXCjrP+wQOF65hJGs3yyMxCgde5vdg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz> <1328116137.15992.6146.camel@triegel.csb>
In-Reply-To: <1328116137.15992.6146.camel@triegel.csb>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Torvald Riegel <triegel@redhat.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, Feb 1, 2012 at 9:08 AM, Torvald Riegel <triegel@redhat.com> wrote:
>
> What do the kernel folks think about the C11 memory model? =A0If you can
> spot any issues in there, the GCC community would certainly like to
> know.

I don't think this is about memory models except very tangentially.

Gcc currently accesses fields in a way that affects *independent*
fields, without checking their memory models at all.

Even original C already has one memory model: "volatile" data is seen
outside the virtual C machine. And Jiri reports that even that
*original* memory model is being violated. We're taling about the one
from about 40 years ago.

So no amount of memory model will ever matter, if gcc can't even get
the 40-year old one right.

Also, the C11 memory model really isn't going to make any difference
to this. Again, because this happens even if we have explicit locking
for the different fields. So they aren't "atomic" or anything like
that, because we do our own (and sufficient) locking. But once the
compiler starts to randomly touch data that just happens to be
adjacent to other data, any memory model about those individual pieces
is going to be entirely immaterial anyway.

Finally: I do not believe for a second that we can actually use the
C11 memory model in the kernel and say "that's sufficient for our
needs". We will continue to have to do things that are "outside the
specs" for the very simple reason that the kernel isn't just some
random application that happens to use pthreads. We do end up doing
much more aggressive threading, with models that C11 simply doesn't
cover.

_Atomic simply isn't going to make any difference to us. Sure, we
might use it in a couple of places (where we have sometimes tried to
use volatile casts, for example), but it would be totally irrelevant
in this case exactly because *neither* field is really atomic - they
are both protected, it's just that they are *separately* protected, so
accessing one does *not* mean that you can access the other, even if
they are next to each other.

                  Linus
