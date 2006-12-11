From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 11 Dec 2006 23:58:18 +0000
Subject: ia64 CONFIG_KEXEC ^ CONFIG_CRASH_DUMP
Message-Id: <617E1C2C70743745A92448908E030B2AE65E20@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The kexec/crash_dump patches for ia64 have gone into Linus'
tree ... but there are some loose ends to tidy up.  One of them
is what is supposed to happen if I configure CONFIG_KEXEC=y with
CONFIG_CRASH_DUMP=n or CONFIG_KEXEC=n with CONFIG_CRASH_DUMP=y.

The current result is build errors unless both are 'n' or both
are 'y'.  Looking at Documentation/kdump/kdump.txt it looks like
the original intent was that CONFIG_KEXEC=y be used for the normal
kernel that you run all the time, and CONFIG_CRASH_DUMP=y be used
for the kernel that you transfer to when bad stuff has happened to
actually dump memory.

But on ia64 I don't think that we need such a distinction.  We don't
need to link the crashdump kernel at a special address, so it can
be the same binary as our normal kernel.

I did take a quick look at untangling KEXEC/CRASH_DUMP ... but
there seem to be a few places where the ia64 port assumes that
both are either set or not set.

Perhaps the path of least resistance would be to just fix
arch/ia64/Kconfig to only offer a single "kexec + crashdump"
option that sets both CONFIG options?  Or are there other
benefits/reasons to keep separate options?

-Tony
