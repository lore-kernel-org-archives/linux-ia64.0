From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 30 Jan 2002 23:13:04 +0000
Subject: Re: [Linux-ia64] Updating to the latest binutils - any tips on how to do it easily?
Message-Id: <marc-linux-ia64-105590698805970@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805968@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805968@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

>Any suggestions on installing a newer binutils? I tried installing=20
>a recient version (binutils-2.11.2 or binutils-2.10.1) to /usr/local
>and had problems with commands compiled with the current compiler,
>(egcs-2.91.66/(egcs-1.1.2 release)), getting a SEGV when they started;=20
>so I backed out the changed binutils installation for now.

There is no IA-64 support in those egcs releases, so you must be talking ab=
out
something else, like x86.  Anyways, regardless of the target, it is never a
good idea for the system compiler to use an assembler from /usr/local.
If you run the command "gcc --print-file-name=CC1", then cd to the directory
containing cc1, and then create a link called "as" that points to the corre=
ct
assembler, then that gcc will always use that assembler.  You may also need=
 to
create a link called "real-ld" that points to the correct linker.

If you install gcc and binutils using the same configure prefix, then that
gcc will find that binutils.  Putting everything in /usr/local is not
necessarily a good idea, since lots of people have /usr/local in their path,
and will then run things in /usr/local accidentally.  If you use a different
prefix for every gcc release you install, you can avoid problems like this.
This may be too much trouble for someone who isn't a gcc hacker though.

>Perhaps the compiler and binutils have to be changed together?

It is common that a new compiler release requires a new binutils release.
Also, it is common that a new gcc requires a new gdb.  It is less common,
but happens sometimes, that a new gcc requires a new glibc or new kernel
because of ABI changes.  This is an issue for IA-64 because it is still
so new, and compiler work was really finished until last year when 3.0.2
came out.  There should be no more major ABI changes after gcc 3.0.2 though.

Jim


