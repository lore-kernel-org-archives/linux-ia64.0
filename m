From: Randy Dunlap <rdunlap@infradead.org>
Date: Mon, 24 Jan 2022 19:30:15 +0000
Subject: Re: [PATCH -next] exit: export make_task_dead()
Message-Id: <0ab7e64d-54ab-ed9d-ed23-75c6902cca25@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220122174834.6493-1-rdunlap@infradead.org>
 <Ye5vR609miJCKdYa@infradead.org>
In-Reply-To: <Ye5vR609miJCKdYa@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, kernel test robot <lkp@intel.com>



On 1/24/22 01:20, Christoph Hellwig wrote:
> On Sat, Jan 22, 2022 at 09:48:34AM -0800, Randy Dunlap wrote:
>> In a config file from "kernel test robot <lkp@intel.com>" for a
>> different problem, this linker error was exposed when
>> CONFIG_IA64_MCA_RECOVERY=m.
>>
>> We could either export make_task_dead() or restrict IA64_MCA_RECOVERY
>> to a bool Kconfig symbol instead of a tristate symbol, so go with the

OK, I'll send a patch to do ^^^that^^^ instead.

>> EXPORT_SYMBOL() path.
>>
>> Fixes this build error:
>>
>> ERROR: modpost: "make_task_dead" [arch/ia64/kernel/mca_recovery.ko] undefined!
>>
>> Fixes: 0e25498f8cd4 ("exit: Add and use make_task_dead.")
>> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
>> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
>> Cc: linux-ia64@vger.kernel.org
>> Cc: Tony Luck <tony.luck@intel.com>
>> Cc: kernel test robot <lkp@intel.com>
>> ---
>>  kernel/exit.c |    1 +
>>  1 file changed, 1 insertion(+)
>>
>> --- linux-next-20220121.orig/kernel/exit.c
>> +++ linux-next-20220121/kernel/exit.c
>> @@ -896,6 +896,7 @@ void __noreturn make_task_dead(int signr
>>  
>>  	do_exit(signr);
>>  }
>> +EXPORT_SYMBOL(make_task_dead);
> 
> EXPORT_SYMBOL_GPL and restricted, please.
> 
> Or even better: force the mca recovery code to be built in.

thanks.
-- 
~Randy
