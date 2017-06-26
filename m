From: Jiri Slaby <jslaby@suse.cz>
Date: Mon, 26 Jun 2017 12:02:31 +0000
Subject: Re: [PATCH 1/1] futex: remove duplicated code and fix UB
Message-Id: <80af8d81-4522-de2d-8289-1ab46565505a@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170621115318.2781-1-jslaby@suse.cz>
 <alpine.DEB.2.20.1706230017520.2221@nanos>
In-Reply-To: <alpine.DEB.2.20.1706230017520.2221@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will.deacon@arm.com>
Cc: mingo@redhat.com, peterz@infradead.org, dvhart@infradead.org, linux-kernel@vger.kernel.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Catalin Marinas <catalin.marinas@arm.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michal Simek <monstr@monstr.eu>, Ralf Baechle <ralf@linux-mips.org>, Jonas Bonn <jonas@southpole.se>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Marti

On 06/23/2017, 09:51 AM, Thomas Gleixner wrote:
> On Wed, 21 Jun 2017, Jiri Slaby wrote:
>> diff --git a/arch/arm64/include/asm/futex.h b/arch/arm64/include/asm/futex.h
>> index f32b42e8725d..5bb2fd4674e7 100644
>> --- a/arch/arm64/include/asm/futex.h
>> +++ b/arch/arm64/include/asm/futex.h
>> @@ -48,20 +48,10 @@ do {									\
>>  } while (0)
>>  
>>  static inline int
>> -futex_atomic_op_inuser(unsigned int encoded_op, u32 __user *uaddr)
> 
> That unsigned int seems to be a change from the arm64 tree in next. It's
> not upstream and it'll cause a (easy to resolve) conflict.

Ugh, I thought the arm64 is in upstream already. Note that this patch
just takes what is in this arm64 fix and makes it effective for all
architectures. So I will wait with v2 until it merges upstream.

So, Will, will you incorporate Thomas' comments into your arm64 fix?

...

> Yes, we probably can't change that anymore, but at least we should make it
> very explicit and add a comment to that effect.

Something like this or do you want a comment yet?
        unsigned int op =         (encoded_op & 0x70000000) >> 28;
        unsigned int cmp =        (encoded_op & 0x0f000000) >> 24;
        int oparg = sign_extend32((encoded_op & 0x00fff000) >> 12, 12);
        int cmparg = sign_extend32(encoded_op & 0x00000fff, 12);

thanks,
-- 
js
suse labs
