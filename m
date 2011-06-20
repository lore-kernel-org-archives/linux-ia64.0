From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Date: Mon, 20 Jun 2011 02:42:47 +0000
Subject: Re: [PATCH 00/10] Enhance /dev/mem to allow read/write of arbitrary
Message-Id: <BANLkTi=MeNcOhxU2TYvaC+xwebxcROnjcw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201106171038.25988.ptesarik@suse.cz>
	<20110617093032.GA19235@elte.hu>
	<201106171155.32062.ptesarik@suse.cz>
In-Reply-To: <201106171155.32062.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-arm-kernel@lists.infradead.org

On Fri, Jun 17, 2011 at 5:55 PM, Petr Tesarik <ptesarik@suse.cz> wrote:
> Dne Pá 17. června 2011 11:30:32 Ingo Molnar napsal(a):
>> * Petr Tesarik <ptesarik@suse.cz> wrote:
>> > This patch series enhances /dev/mem, so that read and write is
>> > possible at any address. The patchset includes actual
>> > implementation for x86.
>>
>> This series lacks a description of why this is desired.
>
> Hi Ingo,
>
>> My strong opinion is that it's not desired at all: /dev/mem never
>> worked beyond 4G addresses so by today it has become largely obsolete
>> and is on the way out really.
>>
>> I'm aware of these current /dev/mem uses:
>>
>>  - Xorg maps below 4G non-RAM addresses and the video BIOS
>>
>>  - It used to have some debugging role but these days kexec and kgdb
>>    has largely taken over that role - partly due to the 4G limit.
>
> It is still used as a "memory source" by Dave Anderson's crash utility for
> live examination of a running system. Redhat has "overcome" the /dev/mem
> deficiencies by writing an out-of-tree re-implementation of /dev/mem, which
> uses /dev/crash instead. As it is an "unnecessary duplication of an existing
> driver", this method was rejected by the project manager here at SUSE.
>
> The suggested alternative was to enhance (or fix) the existing driver. Without
> this patch series there is no way to access high memory. In conjunction with
> CONFIG_HIGHPTE, it makes the crash utility near to useless on anything with
> high memory, because crash can no longer translate virtual to physical
> addresses.
>

How about /proc/kcore? AFAIK, it can access highmem, but Dave didn't consider
it for some reason.
