From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 30 Sep 2002 23:28:12 +0000
Subject: [Linux-ia64] kernel update (relative to 2.5.39)
Message-Id: <marc-linux-ia64-105590701906075@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

With the new patch, I see lots of warnings compiling the various
filesystems (particularly ext3 and reiserfs), as ino_t is defined as
an int on IA64, but is printed in error messages as a long (it's a
long on most other platforms).

There are two ways I can think of to fix this:

      1.  Change the definition of ino_t to be a long, not an int, as
      was done in the sparc64 and ppc64 code.  The comments in
      asm/posix_types.h say these types are used for communication to
      userspace, so maybe that's not an option any more?

      2.  Add casts to long everywhere an ino_t is printed out.  This
      approach is ugly, and requires quite a few changes; and would
      have to be repeated every time other architecture-maintainers
      add new printks.

Is there a better, third, way?  

--
Dr Peter Chubb				    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.

