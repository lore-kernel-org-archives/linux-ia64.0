From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 19 May 2000 19:13:10 +0000
Subject: Re: [Linux-ia64] problem building gnu tool
Message-Id: <marc-linux-ia64-105590678205101@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205100@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205100@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

You can't build a complete cross toolchain unless you have ia64 headers and
libraries.  Just copy the ia64-linux /usr/lib and /usr/include directories
to someplace on your x86 host.  Then point to those copies using the
configure --with-headers and --with-libs options.  The cross toolchain will
then build and work fine.

If all you want to do is build the kernel, then you don't need headers and
libraries.  I haven't done this myself, so I can't give details.  But you
probably already have enough of the toolchain to enable building kernels.

Jim


