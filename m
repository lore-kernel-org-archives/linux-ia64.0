From: Jakub Jelinek <jakub@redhat.com>
Date: Tue, 18 Sep 2001 10:06:18 +0000
Subject: [Linux-ia64] Re: PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805209@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805199@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805199@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 18, 2001 at 11:21:57AM +0200, Luigi Genoni wrote:
> Actually userspace for ultrasparc is only 32 bits, there is a 64 bit
> compiler for the kernel, I think, but I've never seeen 64 bits libraries
> except the ones inside of /usr/lib/gcc-lib/<sprac>/<egcs-xxx>.

Not true:
ldd ./iconv
        libc.so.6 => /lib64/libc.so.6 (0xfffff80000120000)
        /lib64/ld-linux.so.2 => /lib64/ld-linux.so.2 (0xfffff80000000000)
I can put up the rpms somewhere (but as I said, since %multilib support is
broken in rpm ATM, the only way to install this stuff and keep your 32bit
glibc is to unpack it manually).
But so that SPARC 64bit userland is widely used, this means somebody needs
to a) fix rpm or deal somehow with this in dpkg, b) package 64bit libs/apps
up (this may at least for rpm involve some macroizing of spec files where
needed), c) if gcc crashes/miscompiles something (similarly if ld or gas breaks),
send testcases (note that sparc64 is only supported by gcc-2.96-RH, gcc 3.1
CVS head or gcc 3.0.x with SUBREG_BYTE patch).

	Jakub

