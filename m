From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 01 Feb 2012 16:41:59 +0000
Subject: Re: Memory corruption due to word sharing
Message-Id: <CA+55aFy55Q=+pFCZcS9cOM6SL+ZT3sNDB+c4qFvVqwwSpTqJ7g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120201151918.GC16714@quack.suse.cz>
In-Reply-To: <20120201151918.GC16714@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, dsterba@suse.cz, ptesarik@suse.cz, rguenther@suse.de, gcc@gcc.gnu.org

On Wed, Feb 1, 2012 at 7:19 AM, Jan Kara <jack@suse.cz> wrote:
>
> =A0we've spotted the following mismatch between what kernel folks expect
> from a compiler and what GCC really does, resulting in memory corruption =
on
> some architectures.

This is sad.

We've had something like this before due to architectural reasons
(alpha inability to do byte loads and stores leading us to not be able
to have items smaller than a byte sharing a word).

But at least then there was a *reason* for it, not "the compiler is
being difficult for no good reason".

Actually, the *sad* part is not that the compiler does something
unexpected - that's not new - but the usual "..and the gcc crowd
doesn't care, because they can point to paperwork saying it's not
defined". Even if that same paper is actually in the process of
getting updated exactly because it causes problems like ours.

That mentality is not new, of course.

> So it seems what C/GCC promises does not quite match with what kernel
> expects.

The paper C standard can *never* promise what a kernel expects. There
are tons of unspecified things that a compiler could do, including
moving memory around behind our back as long as it moves it back.
Because it's all "invisible" in the virtual C machine in the absence
of volatiles. The fact that the kernel has things like SMP coherency
requirements is simply not covered by the standard. There are tons of
other things not covered by the standard too that are just "that's
what we need".

So C/gcc has never "promised" anything in that sense, and we've always
had to make assumptions about what is reasonable code generation. Most
of the time, our assumptions are correct, simply because it would be
*stupid* for a C compiler to do anything but what we assume it does.

But sometimes compilers do stupid things. Using 8-byte accesses to a
4-byte entity is *stupid*, when it's not even faster, and when the
base type has been specified to be 4 bytes!

>            I'm not really an expert in this area so I wanted to report it
> here so that more knowledgeable people can decide how to solve the issue.=
..

If the gcc people aren't willing to agree that this is actually a flaw
in the standard (one that is being addressed, no less) and try to fix
it, we just have to extend our assumptions to something like "a
compiler would be stupid to ever access anything bigger than the
aligned register-size area". It's still just an assumption, and
compiler people could be crazy, but we could just extend the current
alpha rules to cover not just "int", but "long" too.

Sure, the compiler people could use "load/store multiple" or something
like that, but it would be obviously crazy code, so if it happens past
a register size, at least you could argue that it's a performance
issue and maybe the gcc people would care.

HOWEVER. The problem with the alpha rules (which, btw, were huge, and
led to the CPU designers literally changing the CPU instruction set
because they admitted they made a huge mistake) was never so much the
occasional memory corruption, as the fact that the places where it
could happen were basically almost impossible to find.

So we probably have tons of random places in the kernel that violate
even the alpha rules - because the corruption is so rare, and the
architecture was so rare as to making the corruption even harder to
find.

I assume this code generation idiocy only happens with bitfields? The
problem is, we really don't want to make all bitfields take up 64 bits
just because we might have a lock or something else next to them. But
we could probably re-order things (and then *occasionally* wasting
memory) if we could just find the ones that are problematic.

It's finding the problematic ones that is the issue. Which is why the
compiler should just generate code that matches what we told it to do,
not try to be "clever" in ways that doesn't even help performance! The
compiler simply doesn't know enough about the requirements. Never has,
never will, and this is not about "standards".

                               Linus
