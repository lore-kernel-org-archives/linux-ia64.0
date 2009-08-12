From: Amerigo Wang <amwang@redhat.com>
Date: Wed, 12 Aug 2009 01:27:13 +0000
Subject: Re: [RFC Patch 1/2] kexec: show memory info in /proc/iomem
Message-Id: <4A821A71.5010401@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090811104144.5154.77871.sendpatchset@localhost.localdomain> <A6AD88C3F2289247BE726C37303E1EB8B3A855AD@orsmsx505.amr.corp.intel.com>
In-Reply-To: <A6AD88C3F2289247BE726C37303E1EB8B3A855AD@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-ia64@vger.kernel.org'" <linux-ia64@vger.kernel.org>, 'Neil Horman' <nhorman@redhat.com>, "'Eric W. Biederman'" <ebiederm@xmission.com>, 'Andi Kleen' <andi@firstfloor.org>, "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, 'Ingo Molnar' <mingo@elte.hu>

Yu, Fenghua wrote:
>> +
>> +out_free:
>> +	kfree(kexec_free_res);
>> +	kfree(kexec_res);
>> +out_release:
>> +	release_resource(kexec_res);
>> +	goto out;
>> }
>>     
>
> The order of out_free: and out_release: might be reversed. You need to release_resource first; then kfree. Otherwise the previous failures jump to here and will cause problem.
>   

Ahh, sure! I will fix it. Thanks!

