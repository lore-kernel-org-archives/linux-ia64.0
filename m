From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Wed, 13 May 2020 21:26:35 +0000
Subject: Re: [PATCH] ia64: enable HAVE_COPY_THREAD_TLS, switch to kernel_clone_args
Message-Id: <79e58d9b-5a39-390c-2f0c-0d87b63442b4@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200513204848.1208864-1-christian.brauner@ubuntu.com>
 <3908561D78D1C84285E8C5FCA982C28F7F6266E0@ORSMSX115.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7F6266E0@ORSMSX115.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Christian Brauner <christian.brauner@ubuntu.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Qais Yousef <qais.yousef@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Tony!

On 5/13/20 11:19 PM, Luck, Tony wrote:
>> I tried my very best to test this patch including installing Debian 3
>> and 4 to try and get my hands on a gcc version that would allow
>> cross-compiling for ia64. But no, even that wasn't possible let alone a
>> working qemu for ia64. So this is largely untested but hopefully a
>> straightforward change. If this breaks something we will hear from
>> people if they still care about new kernels on ia64 since they won't be
>> able to get any further than trying to start init. :) If this patch
>> breaks it, I'll fix it.
> 
> My last functional ia64 machine no longer powers on. Unclear if it's just
> a broken power supply or something more serious. With almost nobody
> in offices/labs anymore my search for another machine is proceeding
> slowly.

I could test it.

As for getting a working cross-compiler for ia64 in Debian, this has
been on my TODO list for a while now. Building a cross-compiler for
ia64 is a bit more tricky due to it's dependency on the external
libunwind.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
