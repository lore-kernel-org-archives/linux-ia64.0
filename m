From: Chen Gang <gang.chen@asianux.com>
Date: Thu, 13 Jun 2013 02:43:51 +0000
Subject: Re: [Suggestion] arch/*/include/asm/bitops.h: about __set_bit() API.
Message-Id: <51B931E7.5050406@asianux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <51B30285.6020503@asianux.com> <CA+8MBbK_nfOhZGsd5wU-hyiwh3pHS5c42eiBfxLpCjDgBKUqJg@mail.gmail.com> <CAMuHMdWVx79L=ErRkNMide6xNqQt1RQr0psN8nqoADeV0h768A@mail.gmail.com>
In-Reply-To: <CAMuHMdWVx79L=ErRkNMide6xNqQt1RQr0psN8nqoADeV0h768A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Tony Luck <tony.luck@gmail.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, alpha <linux-alpha@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-am33-list@redhat.com, Linux-Arch <linux-arch@vger.kernel.org>

On 06/11/2013 03:32 PM, Geert Uytterhoeven wrote:
> On Tue, Jun 11, 2013 at 12:26 AM, Tony Luck <tony.luck@gmail.com> wrote:
>> > On Sat, Jun 8, 2013 at 3:08 AM, Chen Gang <gang.chen@asianux.com> wrote:
>>> >> using 'unsigned int *', implicitly:
>>> >>   ./ia64/include/asm/bitops.h:63:__set_bit (int nr, volatile void *addr)
>> >
>> > There is some downside on ia64 to your suggestion.  If "addr" is properly
>> > aligned for an "int", but misaligned for a long ... i.e. addr%8 = 4, then I'll
>> > take an unaligned reference trap if I work with long* where the current code
>> > working with int* does not.
>> >
>> > Now perhaps all the callers do guarantee long* alignment?  But I don't know.
>> >
>> > Apart from uniformity, there doesn't see to be any upside to changing this.
> The address pointers have been supposed to be "long *" for a very long time.
> Probably alpha (the second official Linux platform) did it
> differently, and never
> standardized to "long *".

Excuse me, I am not quite familiar with the details, but I guess, it is
about functional feature issues, not (or not only) about bug issues.

For the architectures which can fully support 64-bit OS, excluding ia64
and alpha, all of them can support setting 64 bits (from 0 to 63) under
64-bit machine.

I am not quite sure whether any sub-systems have already set higher bit
(> 31) under 64-bit machine, but in the future, it seems they could (at
least our API supposed so).


Thanks.
-- 
Chen Gang

Asianux Corporation
