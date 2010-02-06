From: Frans Pop <elendil@planet.nl>
Date: Sat, 06 Feb 2010 20:57:42 +0000
Subject: Re: [PATCH 00/16] remove trailing spaces in messages
Message-Id: <201002062157.44357.elendil@planet.nl>
List-Id: <linux-ia64.vger.kernel.org>
References: <201002061844.45212.elendil@planet.nl>
In-Reply-To: <201002061844.45212.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org

Resending the patch cover letter for vger only as it didn't reach there for 
some reason (# recipients maybe?).

+++++++++++
This is a first series of patches to remove trailing spaces in messages. 
Patches cover arch-specific code plus one fix for PM and one in 
Documentation. Depending on how this series is received I'll continue
with other parts of the kernel.

Benefits are:
- general cleanup and consistency
- minor reduction in kernel size and user's log file size
- reduced annoyance for people writing logcheck rules

The patch for m68k has been rebased against linux-next; all other
patches apply against both mainline and -next (as of 5-2).

Shortstat:
 74 files changed, 135 insertions(+), 136 deletions(-)

Frans Pop (16):
      alpha: remove trailing spaces in messages
      arm: remove trailing spaces in messages
      ia64: remove trailing space in messages
      m68k: remove trailing space in messages
      microblaze: remove trailing space in messages
      mips: remove trailing space in messages
      parisc: remove trailing space in messages
      s390: remove trailing space in messages
      sparc: remove trailing space in messages
      x86: remove trailing space in messages
      blackfin: remove trailing space in messages
      cris/trivial: remove trailing space in message
      powerpc: remove trailing space in messages
      um: remove trailing space in messages
      PM: remove trailing space in message
      trivial: remove trailing space in spidev test program
