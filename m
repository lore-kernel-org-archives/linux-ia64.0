From: Jeff Licquia <licquia@progeny.com>
Date: Tue, 11 Oct 2005 20:49:49 +0000
Subject: More on the ia64 pipe filling problem
Message-Id: <1129063790.4128.55.camel@laptop1>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've been working on patches for a while now, and have learned that
there's more to the problem than a simple read wakeup.  Because the
patch I'm writing is looking less and less trivial, I thought it best to
publicize my thinking and make sure I'm not totally crazy.

To sum up the problem: ia64 (and possibly other architectures) sets
PAGE_SIZE to a multiple of PIPE_BUF by default, as opposed to i386 (and
other architectures), which sets PAGE_SIZE equal to PIPE_BUF.  With the
new pipe buffer code in the 2.6.10 kernel, you have to read some number
of bytes (more than PIPE_BUF, but less than PAGE_SIZE) out of a full
pipe before you can write to it again.  Thus, on architectures where
PAGE_SIZE != PIPE_BUF, there's an argument for a POSIX/SUS violation,
since a read of PIPE_BUF bytes will not always unblock a pipe.
Furthermore, this is an unexpected change in behavior, both as compared
to previous kernels and as compared between architectures.

The exact problem seems to be that the new pipe code allocates multiple
pipe buffers, instead of just one.  Before, the pipe would carefully
consider its available memory before denying a write, but now it only
looks at the end of the buffer chain, either for free space in the last
buffer or for a slot for a new buffer.  Thus, if a pipe read does not
completely empty a buffer, causing the buffer count to drop and making
space for a new buffer at the end, the write state will not change.

This is OK if PIPE_BUF = PAGE_SIZE, since a read of PIPE_BUF bytes will
always clear out a buffer.  On architectures where PIPE_BUF < PAGE_SIZE,
however, those reads will not necessarily clear out a buffer.  Thus, the
atomicity promise PIPE_BUF makes is not actually honored by the kernel;
true atomicity is PAGE_SIZE bytes.

Since PIPE_BUF is an embedded constant for a given glibc build, changing
it isn't really an option (especially where PAGE_SIZE is configurable,
as on ia64).

It could be simply asserted that ia64 kernels must be configured with 4K
page sizes in order to be LSB compliant.  That doesn't sound very
useful.  I imagine there is a benefit to larger page sizes, or the
option wouldn't be available.

The LSB could simply disable those tests on ia64.  One could argue that
the precise definition of "fullness" of a pipe isn't found in the specs
(at least not in the write() call), and that applications cannot deduce
anything about pipe state from PIPE_BUF plus careful recordkeeping.
This would imply, though, that PIPE_BUF is meaningless, which I don't
think is an interpretation of the specs that would see wide support.
Further, at least one test suite explicitly rejects that interpretation,
and getting it changed might be a trick.

My proposed solution: hold back a pipe buffer.  Thus, a "full" pipe
would only fill one less than the total number of allowable buffers.
The last buffer would be controlled by the offset of the first; every
PIPE_BUF bytes the offset of the first buffer moves forward (via reads),
PIPE_BUF bytes would be allowed into the last buffer.  By the time you
fill the last pipe, the first pipe has fewer than PIPE_BUF bytes left in
it, and a single read of PIPE_BUF bytes will clear the buffer and allow
a new one.

Does any of this make sense?  Am I missing something obvious?  More
importantly, am I on the right track?

