From: "Carlos O'Donell" <carlos@systemhalted.org>
Date: Thu, 02 Mar 2017 15:22:18 +0000
Subject: Re: [PATCH] uapi: fix asm/signal.h userspace compilation errors
Message-Id: <CAE2sS1h9QNV+31GMSv8aahJYOb9hFtFp5Aj-yVOfg7cjBHr_kg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170226010156.GA28831@altlinux.org> <CAK8P3a0YX3RGAqWN0mwUJtBsqUX0C+QRtJLrT_UA=wX6Z+q0DA@mail.gmail.com>
In-Reply-To: <CAK8P3a0YX3RGAqWN0mwUJtBsqUX0C+QRtJLrT_UA=wX6Z+q0DA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: "Dmitry V. Levin" <ldv@altlinux.org>, Russell King <linux@armlinux.org.uk>, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf Baechle <ralf@linux-mips.org>, David Howells <dhowells@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <>

On Wed, Mar 1, 2017 at 11:20 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Sun, Feb 26, 2017 at 2:01 AM, Dmitry V. Levin <ldv@altlinux.org> wrote:
>> Include <stddef.h> (guarded by #ifndef __KERNEL__) to fix asm/signal.h
>> userspace compilation errors like this:
>>
>> /usr/include/asm/signal.h:126:2: error: unknown type name 'size_t'
>>   size_t ss_size;
>>
>> As no uapi header provides a definition of size_t, inclusion
>> of <stddef.h> seems to be the most conservative fix available.
>>
>> On the kernel side size_t is typedef'ed to __kernel_size_t, so
>> an alternative fix would be to change the type of sigaltstack.ss_size
>> from size_t to __kernel_size_t for all architectures except those where
>> sizeof(size_t) < sizeof(__kernel_size_t), namely, x32 and mips n32.
>>
>> On x32 and mips n32, however, #include <stddef.h> seems to be the most
>> straightforward way to obtain the definition for sigaltstack.ss_size's
>> type.
>>
>> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
>
> I'm not sure if this is the best fix. We generally should not include one
> standard header from another standard header. Would it be possible
> to use __kernel_size_t instead of size_t?

In glibc we handle this with special use of __need_size_t with GCC's
provided stddef.h.

For example glibc's signal.h does this:

# define __need_size_t
# include <stddef.h>

And...

/* Any one of these symbols __need_* means that GNU libc
   wants us just to define one data type.  So don't define
   the symbols that indicate this file's entire job has been done.  */
#if (!defined(__need_wchar_t) && !defined(__need_size_t)        \
     && !defined(__need_ptrdiff_t) && !defined(__need_NULL)     \
     && !defined(__need_wint_t))

The idea being that the type you want is really defined by stddef.h,
but you just one the one type.

Changing the fundamental type causes the issues you see in patch v2
where sizeof(size_t) < sizeof(__kernel_size_t).

It will only lead to problem substituting the wrong type.

Cheers,
Carlos.
