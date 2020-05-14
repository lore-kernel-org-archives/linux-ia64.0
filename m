From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Thu, 14 May 2020 08:24:25 +0000
Subject: Re: [PATCH] ia64: enable HAVE_COPY_THREAD_TLS, switch to kernel_clone_args
Message-Id: <917c9b03-cfd0-4bcf-d6a6-6aef7489b27b@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200513204848.1208864-1-christian.brauner@ubuntu.com>
 <3908561D78D1C84285E8C5FCA982C28F7F6266E0@ORSMSX115.amr.corp.intel.com>
 <79e58d9b-5a39-390c-2f0c-0d87b63442b4@physik.fu-berlin.de>
 <20200514074606.vkc35syhdep23rzh@wittgenstein>
 <6b298416-1e64-eee7-0bb4-3b1f7f67adc6@physik.fu-berlin.de>
 <20200514075808.krdtypxpag4tfa74@wittgenstein>
In-Reply-To: <20200514075808.krdtypxpag4tfa74@wittgenstein>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christian Brauner <christian.brauner@ubuntu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Qais Yousef <qais.yousef@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi!

On 5/14/20 9:58 AM, Christian Brauner wrote:
>> The machine also serves as a Debian buildd which is why it's a bit more
>> busy than other servers.
> 
> Oh? Does it also produce Debian images for ia64 similar to what is done
> for sparc64?

Yes, it's actually the same person who does this - me ;).

These images should work just fine:

> https://cdimage.debian.org/cdimage/ports/2020-04-19/

The latest snapshot is currently broken due to a regression in initramfs-tools.

>>>> As for getting a working cross-compiler for ia64 in Debian, this has
>>>> been on my TODO list for a while now. Building a cross-compiler for
>>>> ia64 is a bit more tricky due to it's dependency on the external
>>>> libunwind.
>>>
>>> I hit that roadblock as well but yeah, a cross-compiler would be
>>> helpful.
>>
>> It's not difficult, it's just a bit of annoying package work including
>> some trial and error testing.
>>
>> Once the cross-compiler is in Debian, it will be available in Ubuntu as well.
> 
> Would that based on a recent gcc? I vaguely remember a post somwhere
> that gcc 10 or 11 was planning to drop support for ia64?

Yes, that would be the latest gcc. There are no plans at the moment to
drop ia64 from gcc as the backend is already ported to MODE_CC.

m68k was on the brink of being removed, but I started a Bountysource campaign
to convert it from cc0 to MODE_CC and it was eventually saved ;).

> https://www.bountysource.com/issues/80706251-m68k-convert-the-backend-to-mode_cc-so-it-can-be-kept-in-future-releases

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
