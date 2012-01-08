From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Sun, 08 Jan 2012 16:10:09 +0000
Subject: Re: [RFC PATCH 0/9] Remove useless on_each_cpu return value
Message-Id: <CAOtvUMe0pXKTrJGhkc=OFvqYS1R_PXU9qbSAP8Ld5U7NhFvCSw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1325600353-10895-1-git-send-email-gilad@benyossef.com>
	<1325854981.2442.25.camel@twins>
In-Reply-To: <1325854981.2442.25.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Grant Likely <grant.likely@secretlab.ca>, Rob Herring <rob.herring@calxeda.com>, linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, linux-alpha@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Will Deacon <will.deacon@arm.com>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org

On Fri, Jan 6, 2012 at 3:03 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> On Tue, 2012-01-03 at 16:19 +0200, Gilad Ben-Yossef wrote:
>> on_each_cpu() returns as its own return value the return value of
>> smp_call_function(). smp_call_function() in turn returns a hard
>> coded value of zero.
>>
>> Some callers to on_each_cpu() waste cycles and bloat code space
>> by checking the return value to on_each_cpu(), probably for
>> historical reasons.
>
> hysterical raisins,, yumm! :-)
>
>> This patch set refactors callers to not test on_each_cpu()
>> (fixed) return value and then refactors on_each_cpu to
>> return void to avoid confusing future users.
>>
>
> Seems sane enough, fwiw:
>
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Thanks for the review :-)

I just sent out a V2. No changes except I've added the needed signed-off-by.

Gilad


-- 
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"Unfortunately, cache misses are an equal opportunity pain provider."
-- Mike Galbraith, LKML
