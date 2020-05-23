From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Sat, 23 May 2020 19:49:58 +0000
Subject: Re: [PATCH v2] ia64: enable HAVE_COPY_THREAD_TLS, switch to kernel_clone_args
Message-Id: <6a14fbe8-b135-4e69-c2e6-dbb3d70c0afd@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200517151635.3085756-1-christian.brauner@ubuntu.com>
 <20200517151853.z6y42y4npd4plgkb@wittgenstein>
In-Reply-To: <20200517151853.z6y42y4npd4plgkb@wittgenstein>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christian Brauner <christian.brauner@ubuntu.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Qais Yousef <qais.yousef@arm.com>, linux-kernel@vger.kernel.org

Hi!

On 5/17/20 5:18 PM, Christian Brauner wrote:
>> Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
>> ---
>> /* v2 */
>> - Christian Brauner <christian.brauner@ubuntu.com>:
>>   - Continue to preserve afs.pfs in r16. I wasn't clear that r16 needs to
>>     be used because switch stack and load stack rely on it being saved in
>>     r16 and they'll be very unhappy when it's not. r16 is clobbered though
>>     so now the mov loc1=r16 in there makes sense to me.
>>   - Well, it's tested now...
> 
> Tony, I managed to test this now.

Any update on this?

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
