From: "McCaffity, Ray" <ray.mccaffity@wcg.com>
Date: Wed, 20 Jun 2001 17:28:59 +0000
Subject: [Linux-ia64] IA-64 compile flags for gcc
Message-Id: <marc-linux-ia64-105590693005745@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Many times when using gcc, I use certain flags to optimize the compilation,
for example with Solaris8 and a sparc IIe v9 cpu, I would use something
like...

CC=gcc CFLAGS="-O4 -mcpu=v8"; export CC CFLAGS

There are others as well.  Also many times when doing a configure there is
an
option for something like --prefix=/foo/bar --hosth6 to optimize the code
for
my specific hardware.

Does anyone know what the "optimal" flags are for an IA-64 in gcc?  I
realize you
can't always use the ones you want, but if you could...?

I have gone through a lot of the gcc documentation, but there is so much,
and
what I have seen so far doesn't cover this.  Can anyone point me in the
right
direction?

Ray


