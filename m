From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 08 Jan 2002 00:05:17 +0000
Subject: [Linux-ia64] Re: IA64 Kernel Question
Message-Id: <marc-linux-ia64-105590698805769@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805741@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805741@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

To followup on this issue: Robert tried the flush_memory() and the
program still didn't work.

I wrote:

>>>>> On Fri, 4 Jan 2002 14:36:50 -0800, David Mosberger <davidm@hpl.hp.com> said:

  David> The memory allocated by malloc() does indeed have execute
  David> permission turned on.  Linux does this for historical
  David> reasons.

This paragraph is correct in that it's describing the (traditionally)
intended behavior of Linux.  However, it turns out that there is a
platform-independent bug in the kernel which has the effect that the
first few bytes returned by brk() may not be executable.  The reason
this happens is that the ELF executable maps the data (and bss)
section with READ+WRITE rights only and the kernel doesn't turn on
EXECUTE right for the last such page, which usually contains the
initial break value.

So, the upshot of this is that for the time being, on ia64 you'll have
to do mprotect() to be certain that the memory returned by brk() is
executable.

I'm not sure what the long-term solution will be.  My inclination is
to break with tradition and make anonymous memory not exectuable by
default, but it's not clear whether this will be acceptable for all
platforms (x86 won't be affected because, there, the READ right
implies the EXECUTE right).  I'll follow up with a separate mail to
the LKML get a discussion going (I'll cc this list).

	--david

