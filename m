From: Nathan Scott <nathans@sgi.com>
Date: Thu, 09 Oct 2003 01:25:58 +0000
Subject: Re: IA64 ino_t incorrectly sized?
Message-Id: <marc-linux-ia64-106566296013512@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106378281914262@msgid-missing>
In-Reply-To: <marc-linux-ia64-106378281914262@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hi David,

On Wed, Oct 08, 2003 at 04:51:09PM -0700, David Mosberger wrote:
> 
> The mail you're referring to talks about getdents64() only.  What I
> didn't see is an argument why this is the _only_ user visible
> interface that might be affected.  Are there any other interfaces
> (syscalls, /proc/whatever, etc.) that may directly or indirectly be
> affected?

The problem is not the interfaces - they tend to use "long"
directly and will be unaffected.  When I started running our
tests with large inode numbers, for the most part everything
just worked.  Thats because, as Jes said, the IA64 userspace
(libc, etc) is already 64 bit clean, and inode numbers are a
long (directly, not via ino_t) in much of the kernel.

The problem is the ia64 kernel sometimes chops off the high 32
bits of an inode number for no good reason.  Note that ino_t
is not the kernels ubiquitous inode number representation, its
only used for a subset of the internal interfaces and not for
kernel/user interfaces directly.

e.g. the ia64 include/asm-ia64/stat.h uses long for the inode
number field, and the struct inode i_ino is a long also.  So,
for the most part everything works as is - there are corner
cases (i.e. getdents) that this fixes though, as I explained.
It does not change any external interfaces (if it did they'd
be broken already, but I haven't seen any evidence of that in
my testing).

> If not and if the change has been run through a reasonable
> test-suite (LTP?) without ill effects, I'm certainly OK with the
> change.

With this fix, the XFS test suite passes on filesystems with
all inode numbers forced into the >2^32 range.  This includes
a large amount of filesystem/vfs stress covering all fs ops.

Without the fix, getdents and stat can report different inode
numbers for the same file, even though both structures have
sufficient bits for the correct inode number.

cheers.

ps: all of the above holds for 2.4 as well, the same patch
will apply cleanly there.

-- 
Nathan
