From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 30 Sep 2002 23:49:08 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.5.39)
Message-Id: <marc-linux-ia64-105590701906076@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 1 Oct 2002 09:28:12 +1000, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> With the new patch, I see lots of warnings compiling the
  Peter> various filesystems (particularly ext3 and reiserfs), as
  Peter> ino_t is defined as an int on IA64, but is printed in error
  Peter> messages as a long (it's a long on most other platforms).

  Peter> There are two ways I can think of to fix this:

  Peter>       1.  Change the definition of ino_t to be a long, not an
  Peter> int, as was done in the sparc64 and ppc64 code.  The comments
  Peter> in asm/posix_types.h say these types are used for
  Peter> communication to userspace, so maybe that's not an option any
  Peter> more?

  Peter>       2.  Add casts to long everywhere an ino_t is printed
  Peter> out.  This approach is ugly, and requires quite a few
  Peter> changes; and would have to be repeated every time other
  Peter> architecture-maintainers add new printks.

  Peter> Is there a better, third, way?

If we can do it without breaking apps, I'm all for changing ino_t to
64 bits.  Note that "struct stat" already defines the st_ino member as
"unsigned long".  Also, glibc declares ino_t as a 64-bit type.

The thing to do would be to check all system calls that directly or
indirectly depend on ino_t and verify that they'd be OK (and let's not
forget about checking ioctl()...).  The x86 emulation layer would also
have to be checked to make sure that all ino_t values are properly
converted.

	--david

