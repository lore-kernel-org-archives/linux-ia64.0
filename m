From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 30 Oct 2007 02:25:55 +0000
Subject: Re: [PATCH 3/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <47269633.8050409@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4714BE38.60807@jp.fujitsu.com>
In-Reply-To: <4714BE38.60807@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Simon Horman wrote:
> On Tue, Oct 16, 2007 at 10:35:52PM +0900, Hidetoshi Seto wrote:
>> +#define cputime_to_jiffies(__ct)	((__ct) * HZ / NSEC_PER_SEC)
>> +#define jiffies_to_cputime(__jif)	((__jif) * NSEC_PER_SEC / HZ)
>> +#define cputime64_to_jiffies64(__ct)	((__ct) * HZ / NSEC_PER_SEC)
>> +#define jiffies64_to_cputime64(__jif)	((__jif) * NSEC_PER_SEC / HZ)
> 
> It looks like cputime64_to_jiffies64 and cputime_to_jiffies will
> overflow at (((2^64 -1) / HZ) + 1) ns. In the case where HZ is 1000,
> this means it will overflow at (584/1000) years or about 213 days.
> Similarly for cputime_to_clock_t(). Is this a problem?

Exactly.
I guess NSEC_PER_SEC is permanently 10^9, and larger HZ will not be
required soon in this century. Does the following help us?

#define cputime64_to_jiffies64(__ct)	((__ct) / (NSEC_PER_SEC / HZ))
#define jiffies64_to_cputime64(__jif)	((__jif) * (NSEC_PER_SEC / HZ))

Thanks,
H.Seto
