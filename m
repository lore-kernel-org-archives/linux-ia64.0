From: Chas Williams <chas@cmf.nrl.navy.mil>
Date: Wed, 04 Jul 2001 21:34:11 +0000
Subject: Re: [Linux-ia64] patching sys_call_table from a module
Message-Id: <marc-linux-ia64-105590693005819@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005808@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005808@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>You might be able to workaround this for now by providing a stub
>function in your module that sets "gp" and calls your real function.

i took at look at the what the modutil did when loading kernel modules.
the following stub seems to work with one small problem:

GLOBAL_ENTRY(afs_syscall_stub)
      mov r8=-1

      movl r15=0xa000000000034610 /* afs_syscall */;;
      ld8 r16=[r15],8
      mov r14=gp;;
      ld8 gp=[r15]
      mov b6=r16
      br.few b6;;
END(afs_syscall_stub)

0xa000000000034610 is the descriptor for afs_syscall.  if i use
movl r15,afs_syscall;; instead, insmod fails to load the module:

insmod: obj_ia64.c:258: obj_ia64_ins_imm64: Assertion `slot = 1' failed.

i guess i dont know afs_syscall until the module is actually loaded?

