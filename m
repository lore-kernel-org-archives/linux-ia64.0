From: Uros Prestor <uros@turbolinux.com>
Date: Mon, 21 Feb 2000 17:50:36 +0000
Subject: Re: [Linux-ia64] Cant compile compiler
Message-Id: <marc-linux-ia64-105590678204947@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204946@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204946@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Venkatesh Ramamurthy <Venkateshr@ami.com> said: 

> when i compile the ia64 cross compiler , i seem to get error syaing that
> cant include header stdlib.h and unistd.h in file gcc/ libgcc2.c . I
> remember a special mention about these files in IDF . Can anyone point out
> what i am missing?

You need to have IA-64 include files and IA-64 libraries to bootstrap
the compiler.  Install /usr/include and /usr/lib from the Trillian CD
somewhere on your system, install IA-64 kernel sources and make sure
your IA-64 /usr/include/{asm,linux} point to the IA-64 kernel headers.
After you've done this, configure gcc with

    ../src/configure --with-headers=/your/usr/include \
	--with-libs=/your/usr/lib --target=ia64-cygnus-linux \
	--program-prefix=ia64-cygnus-linux-

This should give you the cross compiler with all commands prefixed
with `ia64-cygnus-linux-'.

Uros



