From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 28 Jul 2000 20:44:00 +0000
Subject: Re: [Linux-ia64] Cross compiling problem: relocation truncated to fit ...
Message-Id: <marc-linux-ia64-105590678205241@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205239@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205239@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

You have an out-of-range branch.  Branches can only reach about 16MB directly,
after that they need linker help.

If you have a recent enough toolchain, then -Wl,-relax will make this work.
It should work automatically, but well, eventually it will.  The recent
TurboLinux distribution RPMS have the necessary patches.  I don't believe any
Red Hat distribution RPMS have it yet, but the next release will.

A 32-bit hosted cross compiler will generate worse code than a native compiler.
This is because it is harder to optimize 64-bit values on a 32-bit machine, so 
there are some cases where we just give up and don't perform the optimization
when on a 32-bit host.  Thus the cross compiled application will be bigger,
and more likely to have out-of-range branches.  Don't cross compile unless
you have to.

Jim


