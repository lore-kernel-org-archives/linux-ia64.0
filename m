From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 15 Jan 2002 02:03:30 +0000
Subject: [Linux-ia64] [ANNOUNCE] first prototype of unwind API
Message-Id: <marc-linux-ia64-105590698805827@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[Note: this announcement is cross-posted to the glibc, gcc, and
 linux-ia64 mailing list because I believe this may be of interest to
 various people on these lists.  This will be the only post of this
 sort; all future discussion will happen on the relevant mailing
 lists.  Thanks for your understanding.]

I'm happy to announce a first prototype implementation of a (mostly)
platform-independent unwind API.  The purpose of this API is to
simplify the implementation of applications that need to inspect the
call-chain of a process/thread.  The immediate goal is to use this
library to implement routines such as glibc's backtrace() function and
offer a substitute for the unwind implementation currently in gcc (of
course, it will be up to the glibc and gcc maintainers to decide
if/when this is appropriate...).

Originally, the API was intended for the ia64 platform, but the
current draft is platform-independent with the exception of the
manifest constants for register names (there are a couple of
well-known register names that make it possible to implement, e.g.,
backtraces in a completely platform-independent fashion).

The prototype source code is available at:

  ftp://ftp.hpl.hp.com/pub/linux-ia64/libunwind-0.0.tar.gz
   md5sum: 9a2935bf589331b17cf23defc3e36bbd  libunwind-0.0.tar.gz

The current prototype implementation is limited to the ia64 linux
platform and even that version has received only light testing.  The
main purpose of this release is to increase the exposure of the API
and to collect feedback.  It would also be nice to find people
interested in implementing the API for other platforms (e.g., x86,
Alpha, etc).

For more information, please refer to the README in the top-level
directory of the source distribution.

If this is a topic of interest to you, please consider subscribing to
the "libunwind" mailing list.  Again, see the README for details.

For the next steps, I'm planning to create the glue logic needed to
use libunwind for GCC exception handling.  Once that is working, I'd
like to do some fairly extensive correctness and performance testing.

Needless to say: any and all feedback is welcome.  Note that to limit
SPAM, it is necessary to subscribe to libunwind before you can post to
the list.  If you do not wish to do that but still have comments, just
send them directly to me (davidm@hpl.hp.com).

Thanks,

	--david

