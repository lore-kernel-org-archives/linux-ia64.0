From: Uros Prestor <uros@turbolinux.com>
Date: Tue, 21 Mar 2000 19:58:07 +0000
Subject: Re: [Linux-ia64] crosscompiler ?
Message-Id: <marc-linux-ia64-105590678204989@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204978@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204978@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jim Wilson wrote:

>         Is a crosscompiler for linuix-ia32 available somewhere or is it really
>         necessary to build it by myself ?

You can get the IA-64 crosscompiler toolchain at

     ftp://ftp.turbolinux.com/pub/ia64/RPMS/i386/gnupro-2.9-000303.i386.rpm

This RPM is based on the Mar 3 release of the Cygnus toolchain with some patches
thrown in.  You will get a complete set of binutils and a C compiler.  There is
no gdb and the libstdc++ is missing at the moment.

We will try to keep the crosscompiler RPM current but be warned that we don't use
the crosscompilers internally and that we only did minimal testing of this RPM.
If you have problems with it send email to ia64-dist@turbolinux.com.

Uros

--
Uros Prestor
uros@turbolinux.com





