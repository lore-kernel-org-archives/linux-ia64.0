From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 02 May 2000 22:00:43 +0000
Subject: Re: [Linux-ia64] IP-relative calls in start.S and initfini.c
Message-Id: <marc-linux-ia64-105590678205066@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205064@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205064@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is an optional patch in the list archives that adds support to the
linker for handling out of range calls.  At the moment, it requires that the
user manually specify -Wl,-relax.  You might try using that option to see if
your toolchain already has the patch applied.  If not, then you can patch
your toolchain, rebuild it, and this problem should go away.

Eventually we will have better support for large programs.  That may include
changing some of the start up code to avoid some of the problems that you are
seeing.

Jim


