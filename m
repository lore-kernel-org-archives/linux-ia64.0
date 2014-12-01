From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Mon, 01 Dec 2014 22:23:59 +0000
Subject: Rebuilding a kernel for a proprietary closed-source ia64 module: possible or not?
Message-Id: <CAA9xbM4fj75nf0=EX7W-6PWZn=SitQSk4htbJXx2wijPPF1yhA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Say that I have a proprietary closed-source ia64 kernel module that I
can't rebuild because I'm missing some additional bits (IP library and
Intel compiler runtime library). Guess who I'm talking about ;-)

I however know the exact kernel source and gcc versions that were used
to build this module. I'm however missing the original kernel
configuration, so had to guess it (among other things). Using
zx1_defconfig as first attempt, I've built a kernel that cannot load
the module at the moment.

But diff'ing System.map of the kernel that I've just recompiled with
the one of the kernel that was used to build the proprietary module
shows that the entry points of matching symbols are identical.
Similarly, diff'ing the Module.symvers of my kernel against the one of
the kernel that was used to build the proprietary module shows the
same exported functions, but different hex signatures.

I'm thus wondering if there's a way to rebuild a kernel, passing it in
some ways the information in a given System.map and/or Module.symvers
file in order to impose the entry points of the kernel symbols and the
hex signatures of the exported functions.

Thanks,

     Emeric
