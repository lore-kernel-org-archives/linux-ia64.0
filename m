From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 01:40:25 +0000
Subject: RE: [kvm-ia64-devel] [02/17][PATCH] Implement smp_call_function_mask for ia64
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCFF80C3@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EFE@pdsmsx415.ccr.corp.intel.com> <47EF7C8B.90902@qumranet.com>
In-Reply-To: <47EF7C8B.90902@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Avi Kivity <avi@qumranet.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, Jes Sorensen <jes@sgi.com>, Akio Takebe <takebe_akio@jp.fujitsu.com>, kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, virtualization@lists.linux-foundation.org, Carsten Otte <cotte@de.ibm.com>

Avi Kivity wrote:
> Zhang, Xiantao wrote:
>> 
>> diff --git a/include/linux/smp.h b/include/linux/smp.h
>> index 55232cc..b71820b 100644
>> --- a/include/linux/smp.h
>> +++ b/include/linux/smp.h
>> @@ -56,6 +56,9 @@ int smp_call_function(void(*func)(void *info),
>> void *info, int retry, int wait); 
>> 
>>  int smp_call_function_single(int cpuid, void (*func) (void *info),
>>  				void *info, int retry, int wait);
>> +int smp_call_function_mask(cpumask_t mask,
>> +			   void (*func)(void *), void *info,
>> +			   int wait);
>> 
>> 
> 
> For all other archs, smp_call_function_mask() is declared in
> <asm/smp.h> so please define it there.  A separate patch can move the
> declarations to <linux/smp.h>, since it makes sense to have just one
> declaration (and the uniprocessor version is declared there anyway).

OK, moved it to asm-ia64/smp.h first, although only x86 arch defined the
interface in current code. :) 
Xiantao
