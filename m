From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 01 May 2000 19:35:47 +0000
Subject: Re: [Linux-ia64] bug in fmod on trillian [fmod(-10,1) causes core dump]
Message-Id: <marc-linux-ia64-105590678205059@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205058@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205058@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I tried your testcase on my system.  It worked fine.

Your bug report is incomplete.  You didn't mention what compiler version
you have, or the glibc version, or the kernel version, or the root filesystem
and/or OS release, or the firmware version or the hardware version.  The
problem could be any of those, or something else.

It is pretty unlikely that the compiler miscompiled such a simple testcase.
So I would guess, in order
1) You have a miscompiled glibc.  Try recompiling it or getting a newer one.
2) You have an old buggy gcc.  Try getting a newer one.  Repeat step one.
3) You have old buggy firmware.  Try updating it.

Jim


