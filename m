From: Gustavo Niemeyer <niemeyer@conectiva.com>
Date: Tue, 24 Apr 2001 11:46:26 +0000
Subject: Re: [Linux-ia64] kernel update (second patch relative to 2.4.3)
Message-Id: <marc-linux-ia64-105590693005451@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005334@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005334@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David!!!

> 	- Hack fs/binfmt_elf so that the auxiliary information is
> 	  passed independent of whether the binary is statically or
> 	  dynamically linked (Rich, I haven't run this past Linus yet,
> 	  but I hope he won't have an issue with it; it really makes
> 	  no sense at all to not pass this info for static binaries:
> 	  an ELF file is an ELF file, no matter whether it's static or
> 	  dynamic).

This doesn't seem to be working well here. I've checked both glibc 2.2.1
and the latest 2.2.2 from CVS and I was still getting the following
error:

[root@ia64 /root]# ldd /bin/bash
BUG IN DYNAMIC LINKER ld.so: rtld.c: 614: dl_main: Assertion `_dl_rtld_map.l_libname' failed!
BUG IN DYNAMIC LINKER ld.so: rtld.c: 614: dl_main: Assertion `_dl_rtld_map.l_libname' failed!
ldd: /lib/ld-linux-ia64.so.2 exited with unknown exit code (127)

The problem seems to be the entry point address. glibc does the
following test at elf/rtld.c:392 to check if ld.so is being run as a
program or as an interpreter:

[...]
  if (*user_entry = (ElfW(Addr)) &ENTRY_POINT)
[...]

With your patch, the function _dl_sysdep_start
(sysdeps/generic/dl-sysdep.c:80) changes the user_entry and this test
will always fail.

After reverting the patch referent to binfmt_elf.c, everything is
working fine.

-- 
Gustavo Niemeyer

[ 2AAC 7928 0FBF 0299 5EB5  60E2 2253 B29A 6664 3A0C ]

