From: Jim Wilson <wilson@redhat.com>
Date: Tue, 15 Oct 2002 18:57:07 +0000
Subject: Re: [Linux-ia64] Re: loading a kernel module
Message-Id: <marc-linux-ia64-105590709805164@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805162@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805162@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Interesting, that looks like this relocation type
>  #define R_IA64_PCREL60B         0x48    /* @pcrel(sym + add), brl */
>which is not handled by any version of modutils.  I need :-

That might be an RHL AS toolchain.  The current GNU tools avoid use of brl
because it is implemented via kernel emulation on Itanium hardware, which
causes performance problems for some code.  However, Itanium2 has this
instruction in hardware, and avoiding brl reduces Itanium2 performance, and
presumably anyone who cares about performance is already using Itanium2
hardware, so it makes sense to emit brl by default now.   I think they may
have made this change in the RHL AS toolchain already, but it is unfortunately
not in the FSF sources yet.

You can get brl instructions by changing "#undef USE_BRL" to "#define USE_BRL"
in the BINUTILS bfd/elfxx-ia64.c file.  I believe that is the change that went
into the RHL AS toolchain.  Then write a large enough program, so that you
have a call site that is far enough away from its call target to require brl.

Jim


