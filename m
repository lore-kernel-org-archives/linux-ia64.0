From: navin <navin@students.iiit.net>
Date: Thu, 08 May 2003 08:33:52 +0000
Subject: Re: [Linux-ia64] Building IA-64 toolchain
Message-Id: <marc-linux-ia64-105590723705677@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705654@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705654@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On 7 May 2003, Jim Wilson wrote:

>On Wed, 2003-05-07 at 13:40, navin wrote:
>> 	I even tried copying the nue ia64-hp-something headers files and 
>> giving gcc the option with --header to that directory but it messed up as 
>> i previously mentioned
>
>You never said how this failed.  Your previous message was about a build
>using the non-existent --without-header configure option.  Since I don't
>know what error you got when you used --with-headers, I can't help you.

Na..This is not for kernel building. It for ia64 developemnt (C 
programs).

 CFLAGS="-O2 -Dinhibit_libc" ../gcc-3.2/configure 
--target=ia64-unknown-linux --prefix=/FPS/Bunny/work/ia64.bak/ 
--enable-languages=c --disable-shared --disable-multilib 
--enable-threads=single --with-headers=/FPS/Bunny/work/nue/include 

I have copied /nue/usr/include and given that headers.make reports the 
following error.

In file included from config.h:2,
                 from ../../gcc-3.2/gcc/config/ia64/fde-glibc.c:34:
auto-host.h:344:1: warning: "_GNU_SOURCE" redefined
../../gcc-3.2/gcc/config/ia64/fde-glibc.c:32:1: warning: this is the 
location of the previous definition
../../gcc-3.2/gcc/config/ia64/fde-glibc.c:42:3: #error You need GLIBC 
2.2.4 or later on IA-64 Linux
../../gcc-3.2/gcc/config/ia64/fde-glibc.c:54: warning: `struct 
dl_phdr_info' declared inside parameter list
../../gcc-3.2/gcc/config/ia64/fde-glibc.c:54: warning: its scope is only 
this definition or declaration, which is probably not what you want
../../gcc-3.2/gcc/config/ia64/fde-glibc.c: In function 
`_Unwind_IteratePhdrCallback':
../../gcc-3.2/gcc/config/ia64/fde-glibc.c:64: dereferencing pointer to 
incomplete type
../../gcc-3.2/gcc/config/ia64/fde-glibc.c:65: dereferencing pointer to 
incomplete type
../../gcc-3.2/gcc/config/ia64/fde-glibc.c:69: dereferencing pointer to 
incomplete type
../../gcc-3.2/gcc/config/ia64/fde-glibc.c:70: dereferencing pointer to 
incomplete type
../../gcc-3.2/gcc/config/ia64/fde-glibc.c:77: dereferencing pointer to 
incomplete type
../../gcc-3.2/gcc/config/ia64/fde-glibc.c: In function 
`_Unwind_FindTableEntry':
../../gcc-3.2/gcc/config/ia64/fde-glibc.c:160: warning: implicit 
declaration of function `dl_iterate_phdr'
make[2]: *** [libgcc/./fde-glibc.o] Error 1
make[2]: Leaving directory `/FPS/Bunny/work/gcc-build2/gcc'
make[1]: *** [libgcc.a] Error 2
make[1]: Leaving directory `/FPS/Bunny/work/gcc-build2/gcc'
make: *** [all-gcc] Error 2

glibc-2.2.93         glibc-common-2.2.93  

Please note that i have not include --with-libs . Hope this libs are 
fine.Also i have 2.3.

>
>> The problem is that building an alpha target is easy .But when i apply 
>> the same rules to ia64 it breaks.GCC breaks.
>
>Why does this not work for IA-64?  A build procedure that works for
>alpha-linux should also work for ia64-linux.

Exactly / The build procedure should work for any target system.
Also in the previous case i didn't have to copy the header files.Maybe 
they are compatible with the standard  header files and this one is not.

>
>Jim
>
>
>
>_______________________________________________
>Linux-IA64 mailing list
>Linux-IA64@linuxia64.org
>http://lists.linuxia64.org/lists/listinfo/linux-ia64
>



