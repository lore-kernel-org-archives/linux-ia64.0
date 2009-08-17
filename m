From: Amerigo Wang <amwang@redhat.com>
Date: Mon, 17 Aug 2009 09:50:21 +0000
Subject: Re: [Patch 8/8] kexec: allow to shrink reserved memory
Message-Id: <4A8927DD.6060209@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090812081731.5757.25254.sendpatchset@localhost.localdomain>	<20090812081906.5757.39417.sendpatchset@localhost.localdomain>	<m1bpmk8l1g.fsf@fess.ebiederm.org> <4A83893D.50707@redhat.com>	<m1eirg5j9i.fsf@fess.ebiederm.org> <4A83CD84.8040609@redhat.com> <m1tz0avy4h.fsf@fess.ebiederm.org>
In-Reply-To: <m1tz0avy4h.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Eric W. Biederman wrote:
> Amerigo Wang <amwang@redhat.com> writes:
>
>   
>> Not that simple, marking it as "__init" means it uses some "__init" data which
>> will be dropped after initialization.
>>     
>
> If we start with the assumption that we will be reserving to much and
> will free the memory once we know how much we really need I see a very
> simple way to go about this. We ensure that the reservation of crash
> kernel memory is done through a normal allocation so that we have
> struct page entries for every page.  On 32bit x86 that is an extra 1MB
> for a 128MB allocation.
>
> Then when it comes time to release that memory we clear whatever magic
> flags we have on the page (like PG_reserve) and call free_page.
>   

Hmm, my MM knowledge is not good enough to judge if this works...
I need to check more MM source code.

Can any MM people help?

Thanks.

