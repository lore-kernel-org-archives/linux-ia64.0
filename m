From: Amerigo Wang <amwang@redhat.com>
Date: Mon, 24 Aug 2009 02:02:08 +0000
Subject: Re: [Patch 1/8] kexec: allow to shrink reserved memory
Message-Id: <4A91F4A0.2040009@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090821065637.4855.32234.sendpatchset@localhost.localdomain>	<20090821065650.4855.53279.sendpatchset@localhost.localdomain> <m18whcr5i8.fsf@fess.ebiederm.org>
In-Reply-To: <m18whcr5i8.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, kamezawa.hiroyu@jp.fujitsu.com, Anton Vorontsov <avorontsov@ru.mvista.com>

Eric W. Biederman wrote:
> Amerigo Wang <amwang@redhat.com> writes:
>
>   
>> +
>> +	start = roundup(start, PAGE_SIZE);
>> +	end = roundup(start + new_size, PAGE_SIZE);
>> +
>> +	for (addr = end; addr < crashk_res.end; addr += PAGE_SIZE) {
>> +		ClearPageReserved(pfn_to_page(addr >> PAGE_SHIFT));
>> +		init_page_count(pfn_to_page(addr >> PAGE_SHIFT));
>> +		free_page((unsigned long)__va(addr));
>> +		totalram_pages++;
>>     
>
> Any chance we can move this inline snippet into a helper function in
> -mm.  To expose what is happening here to the mm developers.
>
>   

Yes, I believe so. In fact I also wanted to do this, but I forgot before 
I sent these patches... Will do it in the next version.

Thanks.


