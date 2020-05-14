From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Thu, 14 May 2020 08:51:01 +0000
Subject: Re: [PATCH] ia64: enable HAVE_COPY_THREAD_TLS, switch to kernel_clone_args
Message-Id: <389d6a23-b691-c7d0-e276-f9ba43084d73@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200513204848.1208864-1-christian.brauner@ubuntu.com>
 <3908561D78D1C84285E8C5FCA982C28F7F6266E0@ORSMSX115.amr.corp.intel.com>
 <79e58d9b-5a39-390c-2f0c-0d87b63442b4@physik.fu-berlin.de>
 <20200514074606.vkc35syhdep23rzh@wittgenstein>
 <6b298416-1e64-eee7-0bb4-3b1f7f67adc6@physik.fu-berlin.de>
 <20200514075808.krdtypxpag4tfa74@wittgenstein>
 <917c9b03-cfd0-4bcf-d6a6-6aef7489b27b@physik.fu-berlin.de>
 <20200514083739.m2idxcxof4jyreck@wittgenstein>
In-Reply-To: <20200514083739.m2idxcxof4jyreck@wittgenstein>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christian Brauner <christian.brauner@ubuntu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Qais Yousef <qais.yousef@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 5/14/20 10:37 AM, Christian Brauner wrote:
>>> Oh? Does it also produce Debian images for ia64 similar to what is done
>>> for sparc64?
>>
>> Yes, it's actually the same person who does this - me ;).
> 
> Well thank you very much. Thanks to this I was able to test my sparc
> patches in qemu. :)

I really appreciate it that kernel developers are testing their patches on
all architectures. Thank you for your work as well!

>> These images should work just fine:
>>
>>> https://cdimage.debian.org/cdimage/ports/2020-04-19/
> 
> Oh I didn't find these images when searching for them. They would be
> super helpful but there's no qemu for ia64 anymore that's useable. I had
> tried building qemu from an old source based on a gsoc project for an
> ia64 port but that turned out to be more involved than writing ia64
> assembly itself. :)

There is ski but I have never used it:

> http://ski.sourceforge.net/

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
