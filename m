From: "Wichmann, Mats D" <mats.d.wichmann@intel.com>
Date: Wed, 25 Sep 2002 19:40:20 +0000
Subject: RE: [Linux-ia64] platform detection at run-time
Message-Id: <marc-linux-ia64-105590701906063@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906051@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906051@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Nathan> What are the puzzle pieces of a "properly configured
>   Nathan> machine?"  It's worked on all Redhat 7.2 based systems I've
>   Nathan> run.
> 
> It's wrong if execve("/bin/uname") returns a different value than the
> x86 uname() system call.  To ensure consistency, it is necessary to
> install the x86 version of uname in /emul/ia32-linux/bin/.
> 
> I'd hope that stuff like this will eventually be spelled out in the
> LSB documents.


Ahem.  I'm listening.  There's a draft ia64 LSB spec
available for review here:

http://www.linuxbase.org/spec/lsbia64review.html

you can also go directly to the doc from here:

http://www.linuxbase.org/spec/index.shtml

(and file bugs in the normal way through sourceforge,
which is better, since if you're logged in when you
file it you get notifications back as it progresses).

It got tagged with a close date of this Friday,
but if there's any enthusiasm forthcoming, I don't
mind keeping that open a bit longer.  Seems like
the announcement of the review period that was
supposed to go "everywhere" never did get sent to
this list, at least I don't recall seeing it.
(Prob'ly should have done that myself; sorry).

We've really kind of sidestepped some of these issues, 
for a variety of reasons.

First off, there was some effort a while back to talk
about /proc/cpuinfo, and then that was killed.  I don't
recall the whole discussion, but /proc/cpuinfo will NOT
be standardized in the LSB in the forseeable future.

Secondly, the current consensus seems to be that issues
of compatibility library and file location will be resolved
behind the scenes, so the spec should not say much about 
them. For example, an ia32 binary will be linked against
ld-linux.so.2 (or for an LSB application, ld-lsb.so.1),
and it's that dynamic linker's work to figure out
things about the libraries.  There's already, for
example, one ia32 implementation where the LSB dynamic
linker actually picks libraries out of /lib/lsb
instead of /lib or /usr/lib.  That's allowed....

The /emul/linux-i386 stuff is a path prefix supplied
by the kernel, right?  I really don't know whether
that should be mentioned in the spec or not: does
an application actually need to know that this is
happening, or is it completely transparent?  Of
course a given system has to "get it right".

I do think the issue that started this thread is worthy
of some sort of mention in the LSB.

The LSB in general is following FHS ideas, I know
that discussion spilled onto this list about a year
ago.

One thing that's been batted around is the name of
the dynamic linker:  it's been tentatively called
ld-lsb-ia64.so.1 to parallel the "standard" Linux
one, but other folks with 64-bit architectures
prefer a more generic ld-lsb-64.so.1, which would be
the same name regardless of architecture.  Since this 
doesn't affect ld-linux, there's no backwards-compatibility
issue with that name...

Anyway, any and all comments on this stuff gratefully
accepted.

Thanks,

Mats Wichmann
(if you couldn't guess, I'm Intel's current representative 
to the LSB)

