From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 24 Aug 2009 07:43:18 +0000
Subject: Re: [Patch 5/8] ia64: implement crashkernel=auto
Message-Id: <20090824074318.GB2424@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090821065637.4855.32234.sendpatchset@localhost.localdomain> <20090821065729.4855.47860.sendpatchset@localhost.localdomain> <20090821172407.d3a5cd2b.akpm@linux-foundation.org> <20090822111816.GA12281@elte.hu> <4A91F57D.10708@redhat.com>
In-Reply-To: <4A91F57D.10708@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, nhorman@redhat.com, ebiederm@xmission.com, andi@firstfloor.org, bernhard.walle@gmx.de, fenghua.yu@intel.com, kamezawa.hiroyu@jp.fujitsu.com, avorontsov@ru.mvista.com


* Amerigo Wang <amwang@redhat.com> wrote:

> Ingo Molnar wrote:
>>
>> e) All the 'else' statements are superflous and make it all harder    
>> to read.
>>
>> f) 2ULL<<30 should be written as 1ULL<31, to keep things consistent.
>>   
>
> Hi,
>
> The reason that I kept 2ULL<<30 instead of 1ULL<<31 is that '1<<30' is  
> exactly 1G, so 2ULL<<30 can be easily read as 2G. ;)

i have no trouble reading 1ULL<<31 as 2G ;-) OTOH, the logic and 
pattern of the comparisons (especially without the comment) looked 
odd at first sight, until i noticed this.

	Ingo
