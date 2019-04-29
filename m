From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Mon, 29 Apr 2019 10:38:17 +0000
Subject: Re: [PATCH] ia64: fix ptrace(PTRACE_GETREGS) (unbreaks strace, gdb)
Message-Id: <def7f1cf-96b1-b0a9-88b8-3d24eb3b6075@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180202221224.16597-1-slyfox@gentoo.org>
In-Reply-To: <20180202221224.16597-1-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Sergei Trofimovich <slyfox@gentoo.org>, Frank Scheiner <frank.scheiner@web.de>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hello!

Is there a chance that Sergey's patch from [1] could get applied upstream?

Currently, the kernel in Debian doesn't boot on the RX2800 and crashes very
early directly after the bootloader. I can also confirm that both strace
and gdb currently don't build on Debian/ia64 due to this particular bug.

Thanks,
Adrian

> [1] https://lkml.org/lkml/2018/2/2/914

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
