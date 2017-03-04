From: "Carlos O'Donell" <carlos@systemhalted.org>
Date: Sat, 04 Mar 2017 01:23:20 +0000
Subject: Re: [PATCH] uapi: fix asm/signal.h userspace compilation errors
Message-Id: <CAE2sS1i-xezJu2hHfzOxpCMZHc2J+dsturtqFPMRWHa6mm6ccQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170226010156.GA28831@altlinux.org> <CAK8P3a0YX3RGAqWN0mwUJtBsqUX0C+QRtJLrT_UA=wX6Z+q0DA@mail.gmail.com>
 <CAE2sS1h9QNV+31GMSv8aahJYOb9hFtFp5Aj-yVOfg7cjBHr_kg@mail.gmail.com> <20170302154845.GB3503@altlinux.org>
In-Reply-To: <20170302154845.GB3503@altlinux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dmitry V. Levin" <ldv@altlinux.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Russell King <linux@armlinux.org.uk>, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ralf Baechle <ralf@linux-mips.org>, David Howells <dhowells@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.>

On Thu, Mar 2, 2017 at 10:48 AM, Dmitry V. Levin <ldv@altlinux.org> wrote:
> On Thu, Mar 02, 2017 at 10:22:18AM -0500, Carlos O'Donell wrote:
>> On Wed, Mar 1, 2017 at 11:20 AM, Arnd Bergmann <arnd@arndb.de> wrote:
>> > On Sun, Feb 26, 2017 at 2:01 AM, Dmitry V. Levin <ldv@altlinux.org> wrote:
>> >> Include <stddef.h> (guarded by #ifndef __KERNEL__) to fix asm/signal.h
>> >> userspace compilation errors like this:
>> >>
>> >> /usr/include/asm/signal.h:126:2: error: unknown type name 'size_t'
>> >>   size_t ss_size;
>> >>
>> >> As no uapi header provides a definition of size_t, inclusion
>> >> of <stddef.h> seems to be the most conservative fix available.
> [...]
>> > I'm not sure if this is the best fix. We generally should not include one
>> > standard header from another standard header. Would it be possible
>> > to use __kernel_size_t instead of size_t?
>>
>> In glibc we handle this with special use of __need_size_t with GCC's
>> provided stddef.h.
>>
>> For example glibc's signal.h does this:
>>
>> # define __need_size_t
>> # include <stddef.h>
>
> Just to make it clear, do you suggest this approach for asm/signal.h as well?

The kernel is duplicating userspace headers in the UAPI implementation
and running into exactly the same problems we have already solved in
userspace. We currently have no better solution than the "__need_*"
interface for avoiding the duplication of the type definitions and the
problems that come with that.

I am taking this up with senior glibc developers on libc-alpha to see
if we have a better suggestion. If you give me 72 hours I'll either
have a better suggestion or the acknowledgement that my suggestion is
the best practical solution we have.

Note that in a GNU userspace stddef.h here comes from gcc, which
completes the implementation of the C development environment that
provides the types you need. The use of "__need_size_t" is a collusion
between the components of the implementation and use by the Linux
kernel would mean expecting something specific to a GNU
implementation.

I might suggest you use include/uapi/linux/libc-compat.h in an attempt
to abstract away the GNU-specific magic for getting just size_t from
stddef.h. That way you have documented the places that other runtime
authors need to fill out for things to work.

Cheers,
Carlos.
