From: Jim Wilson <wilson@cygnus.com>
Date: Mon, 21 May 2001 23:12:39 +0000
Subject: Re: [Linux-ia64] Buggy unwind tables in user space
Message-Id: <marc-linux-ia64-105590693005637@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005627@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005627@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Most IA64 distributions contain a bad version of crtn.o.  Executables
>or shared libraries built with this file have invalid unwind data.

I'm assuming this is a glibc problem, and that there is nothing I need to do.

Glibc by default creates crti/crtn by compiling one C file, and then spliting
the output into two assembly language files.  This works on systems with
dumb assemblers.  It does not work on IA-64.  This was changed in August 2000.
crti/crtn are now generated from IA-64 assembly.

>Correction.  Redhat 7.0.98 (Wolverine) also has a buggy version of
>crtn.o.

You will have to elaborate.  My copy here has no unwind info, and hence the
unwind info can't possibly be missing relocations.

If your complaint is that there is no unwind info, then it needs to be
added to the assembly code in glibc.  See libc/sysdeps/ia64/elf/initfini.c.

Jim

