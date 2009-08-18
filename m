From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 18 Aug 2009 08:25:52 +0000
Subject: Re: [Patch 8/8] kexec: allow to shrink reserved memory
Message-Id: <20090818172552.779d0768.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090812081731.5757.25254.sendpatchset@localhost.localdomain>
	<20090812081906.5757.39417.sendpatchset@localhost.localdomain>
	<m1bpmk8l1g.fsf@fess.ebiederm.org>
	<4A83893D.50707@redhat.com>
	<m1eirg5j9i.fsf@fess.ebiederm.org>
	<4A83CD84.8040609@redhat.com>
	<m1tz0avy4h.fsf@fess.ebiederm.org>
	<4A8927DD.6060209@redhat.com>
	<20090818092939.2efbe158.kamezawa.hiroyu@jp.fujitsu.com>
	<4A8A4ABB.70003@redhat.com>
In-Reply-To: <4A8A4ABB.70003@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

On Tue, 18 Aug 2009 14:31:23 +0800
Amerigo Wang <amwang@redhat.com> wrote:
> Hi, thank you!
> > Can I have a question ?
> >
> >   - How crash kernel's memory is preserved at boot ?
> >   
> 
> Use bootmem, I think.
> 
I see.

In x86,
 
  setup_arch()
	-> reserve_crashkernel()
		-> find_and_reserve_crashkernel()
			-> reserve_bootmem_generic()

Then, all "active range" is already registered and there are memmap.


> >     It's hidden from the system before mem_init() ?
> >   
> 
> Not sure, but probably yes. It is reserved in setup_arch() which is 
> before mm_init() which calls mem_init().
> 
> Do you have any advice to free that reserved memory after boot? :)
> 

Let's see arch/x86/mm/init.c::free_initmem()

Maybe it's all you want.

	- ClearPageReserved()
	- init_page_count()
	- free_page()
	- totalram_pages++

But it has no argumetns. Maybe you need your own function or modification.
online_pages() does very similar. But, hmm,.. writing something open coded one
for crashkernel is not very bad, I think.

Thanks,
-Kame







