From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 10 Feb 2004 21:16:21 +0000
Subject: Re: offsets.h and 32 -> 64 bit cross-compiling
Message-Id: <16425.18981.307800.659570@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <401DA58C.8070105@kegel.com>
In-Reply-To: <401DA58C.8070105@kegel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 01 Feb 2004 17:19:08 -0800, Dan Kegel <dank@kegel.com> said:

  Dan> Sadly, that fix seems to be insufficient.

  Dan> On my x86 build machine, 'make ARCH=ia64 dep' for linux-2.4.21 now fails with errors like

  Dan> gcc -g -O2 -Wall -D__KERNEL__ -I/cross/linux-2.4.21/include -DKBUILD_BASENAME= print_offsets.c -o print_offsets

Umh, you're using the wrong compiler.  You must use the IA-64
cross-compiler for print_offsets.c.  That's the entire point of
generating offsets.h at build-time: to ensure the definitions match
your (IA-64) compiler (and kernel-configuration).

When cross-compiling, you must set CROSS_COMPILE to the path that
contains the cross-tools.  When you do that, print_offsets.c will only
be translated to print_offsets.s and then converted to offsets.h via a
small awk-script.  Something like:

	make CROSS_COMPILE=/opt/ia64-cross-compiler/bin/

should do (with the correct path of course...).

	--david
