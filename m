From: Christoph Rohland <cr@sap.com>
Date: Thu, 27 Apr 2000 17:39:26 +0000
Subject: Re: [Linux-ia64] ld failure
Message-Id: <marc-linux-ia64-105590678205057@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205047@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205047@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jim Wilson <wilson@cygnus.com> writes:

> There is an optional patch available for the current stable toolchain that
> fixes this.  There are a few details to work out.
> 1) It uses the linker relaxation support, which isn't the default.
>    So for the moment the user needs to manually specify -Wl,-relax
>    on the gcc command line.
> 2) It uses the brl instruction which the Itanium does not implement.
>    The kernel needs to emulate the instruction.  I know that people
>    are working on this kernel support, but I don't know if it is
>    available yet.  So you will be able to link the program, but you
>    may not be able to run it.
> 3) The ABI does not define relocations for brl yet, so we invented
>    our own.  These will have to change when standard relocations are
>    specified, which may result in a user visble ABI change.

O.K. I applied the patch and now I get:

/usr/bin/ld: dw: __gp does not cover short data segment 

Greetings
                Christoph


