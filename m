From: Amerigo Wang <amwang@redhat.com>
Date: Fri, 28 Aug 2009 10:04:25 +0000
Subject: Re: [Patch 4/8] ia64: implement crashkernel=auto
Message-Id: <4A97ABA9.8030604@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090827031800.4534.94868.sendpatchset@localhost.localdomain> <20090827031848.4534.40440.sendpatchset@localhost.localdomain> <A6AD88C3F2289247BE726C37303E1EB8B949E358@orsmsx505.amr.corp.intel.com> <4A965F3A.5070007@redhat.com> <A6AD88C3F2289247BE726C37303E1EB8B949E7A3@orsmsx505.amr.corp.intel.com>
In-Reply-To: <A6AD88C3F2289247BE726C37303E1EB8B949E7A3@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, 'Anton Vorontsov' <avorontsov@ru.mvista.com>, "Luck, Tony" <tony.luck@intel.com>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>, 'Neil Horman' <nhorman@redhat.com>, "'Eric W. Biederman'" <ebiederm@xmission.com>, "'kamezawa.hiroyu@jp.fujitsu.com'" <kamezawa.hiroyu@jp.fujitsu.com>, 'Andi Kleen' <andi@firstfloor.org>, 'Michael Ellerman' <michael@ellerman.id.au>, "'M. Mohan Kumar'" <mohan@in.ibm.com>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "'bernhard.walle@gmx.de'" <bernhard.walle@gmx.de>, 'Ingo Molnar' <mingo@elte.hu>

Yu, Fenghua wrote:
>>>> +	unsigned long long ret;
>>>> +
>>>> +	if (total_size >= GBYTES(4) && total_size < GBYTES(12))
>>>> +		ret = MBYTES(256);
>>>> +	else if (total_size >= GBYTES(12) && total_size < GBYTES(128))
>>>> +		ret = MBYTES(512);
>>>> +	else if (total_size >= GBYTES(128) && total_size < GBYTES(256))
>>>> +		ret = MBYTES(768);
>>>> +	else if (total_size >= GBYTES(256) && total_size < GBYTES(378))
>>>> +		ret = MBYTES(1024);
>>>> +	else if (total_size >= GBYTES(318) && total_size < GBYTES(512))
>>>> +		ret = MBYTES(1536);
>>>> +	else if (total_size >= GBYTES(512) && total_size < GBYTES(768))
>>>> +		ret = MBYTES(2048);
>>>> +	else
>>>> +		ret = MBYTES(3072);
>>>> +	if (!ia64_platform_is("sn2") && !ia64_platform_is("uv"))
>>>> +		if (ret > GBYTES(4))
>>>> +			ret = ret / GBYTES(4) * MBYTES(256);
>>>>
>>>>         
>>> This code doesn't make sense to me. What you really want is following
>>>       
>> code, right?
>>     
>>> +		if (total_size > GBYTES(4))
>>> +			ret = total_size / GBYTES(4) * MBYTEST(256)
>>>
>>>
>>>       
>> Nope. Check check_crashkernel_memory().
>>     
>
> This statement will be ALWAYS false:
> +		if (ret > GBYTES(4))
> since ret's max value is 3GB after the above total_size checks.
>
> So the code doesn't make sense. Did I miss something?
>   

Oops, in fact it was supposed to be:

  if (ret + base > GBYTES(4))
    //blah blah

Hmm, but is it possible for ia64 to choose a base address above 1G? If 
no, that code can be removed.

Thanks!



