From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 10 Jan 2001 00:54:03 +0000
Subject: Re: [Linux-ia64] IA-64 cross compiler binary
Message-Id: <marc-linux-ia64-105590678205906@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205861@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205861@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Where can you download the latest IA-64 cross compilers in binary form?

I am not aware of anyone publicly distributing IA-64 gcc cross compiler
binaries.  It is a lot of work to build and maintain them, and I don't have
time to do it myself.

Sources for the latest IA-64 GNU toolchain can be found at ftp.cygnus.com
in pub/ia64-linux.  It isn't too hard to build them cross.  Just copy
/usr/include and /usr/lib from the ia64-linux target to the host, and then
use configure with --target=ia64-linux --with-libs=<path to ia64 /usr/lib>
--with-headers=<patch to ia64 /usr/include>.

Jim

