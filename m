From: Arun Sharma <arun.sharma@intel.com>
Date: Thu, 17 Apr 2003 00:04:10 +0000
Subject: Re: [Linux-ia64] ia32 subsystem in 2.5.67
Message-Id: <marc-linux-ia64-105590723705525@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705513@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705513@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Arun Sharma <arun.sharma@intel.com> writes:

> We saw this behavior with 2.5.59 also. The attached work around should
> take care of the problem temporarily. Last time this happened, IA-32
> programs were doing mmaps, whose size was one page bigger than the
> size of the underlying file (even after rounding up the file size).
> 
> I never got a chance to figure out why glibc was doing mmaps with the
> "wrong" size. Also, I failed to reproduce the problem with a more
> recent (RH 8.0) glibc.
> 
> Which version of IA-32 glibc were you using ?

Some more details on the issue:

The problem libc.so.6 binary seems to be the one shipping with Redhat
7.1 IA-32 and Redhat Advanced Server 2.1 IPF (the RPM is named
x86-compat-libs-7.2-1.src.rpm but the SPEC file says the binaries
were copied from Redhat 7.1). I'm yet to look at the source for this
binary. But here are some details:

$ ls -l libc.so.6 
-rwxr-xr-x    1 adsharma adsharma  1282588 Apr 16 16:20 libc.so.6

When run on a IA-32 box, strace shows:

open("/home/adsharma/libc.so.6", O_RDONLY) = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\360\306"..., 1024) = 1024
fstat64(3, {st_mode=S_IFREG|0755, st_size82588, ...}) = 0
old_mmap(NULL, 1299272, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 0x40018000
               ^^^^^^^
mprotect(0x4014c000, 37704, PROT_NONE)  = 0
old_mmap(0x4014c000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3, 0x133000) = 0x4014c000
old_mmap(0x40152000, 13128, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x40152000

Since 1299272 > PAGE_END(1282588) copy_from_user fails.

This problem doesn't exist with the libc.so.6 on RH 8.0 and 9.0:

Redhat 8.0:

open("/lib/i686/libc.so.6", O_RDONLY)   = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\220Y\1"..., 1024) = 1024
fstat64(3, {st_mode=S_IFREG|0755, st_size95734, ...}) = 0
old_mmap(0x42000000, 1239844, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 0x42000000

Redhat 9.0:

open("/lib/tls/libc.so.6", O_RDONLY)    = 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0`V\1B4\0"..., 512) = 512
fstat64(3, {st_mode=S_IFREG|0755, st_size31064, ...}) = 0
old_mmap(0x42000000, 1257224, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) = 0x42000000

But it looks like this can happen to DSOs other than libc.so.6. In
your case it seems to have happened with librt.so.1. I still don't
have an answer for why this (map size > file size) happens, but it
seems to be harmless in IA-32 land, but is a problem when we do mmap
sub paging on IPF.

So perhaps the patch I mailed earlier today should be more than a
temporary workaround ;)

        -Arun


