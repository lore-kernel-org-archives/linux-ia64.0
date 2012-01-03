From: Gilad Ben-Yossef <gilad@benyossef.com>
Date: Tue, 03 Jan 2012 16:08:33 +0000
Subject: Re: [RFC PATCH 0/9] Remove useless on_each_cpu return value
Message-Id: <CAOtvUMfWRLbXRksacPbO7qWtufsdwh07cn9ko40_A_vxhcDTUw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1325600353-10895-1-git-send-email-gilad@benyossef.com>
	<op.v7iidbwz3l0zgt@mpn-glaptop>
In-Reply-To: <op.v7iidbwz3l0zgt@mpn-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Michal Nazarewicz <mina86@mina86.com>
Cc: linux-kernel@vger.kernel.org, David Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Grant Likely <grant.likely@secretlab.ca>, Rob Herring <rob.herring@calxeda.com>, linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, linux-alpha@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Will Deacon <will.deacon@arm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org

2012/1/3 Michal Nazarewicz <mina86@mina86.com>:
> On Tue, 03 Jan 2012 15:19:04 +0100, Gilad Ben-Yossef <gilad@benyossef.com>
> wrote:
>>
>> on_each_cpu() returns as its own return value the return value of
>> smp_call_function(). smp_call_function() in turn returns a hard
>> coded value of zero.
>>
>> Some callers to on_each_cpu() waste cycles and bloat code space
>> by checking the return value to on_each_cpu(), probably for
>> historical reasons.
>>
>> This patch set refactors callers to not test on_each_cpu()
>> (fixed) return value and then refactors on_each_cpu to
>> return void to avoid confusing future users.
>>
>> In other words, this patch aims to delete 18 source code lines
>> while not changing any functionality :-)
>>
>> I tested as best as I could the x86 changes and compiled some
>> of the others, but I don't have access to all the needed hardware
>> for testing. Reviewers and testers welcome!
>
>
> Other then the lack of Signed-off-by in the patches, looks good to me,

Blimey! I'll resend with a proper Signed-off-by after more people have
a chance to
comment. And thanks for the review.

> even though personally I'd choose a bottom-up approach, ie. make
> smp_call_function() return void and from that conclude that
> on_each_cpu() can return void. =A0With those patches, we have a situation,
> where smp_call_function() has a return value which is then lost for no
> immediately apparent reason lost in on_each_cpu().

There are so many call site of smp_call_function() that do not check the
return value right now that I think we can tolerate it for just a
little bit longer
until that get fixed as well... :-)

Thanks,
Gilad


--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"Unfortunately, cache misses are an equal opportunity pain provider."
-- Mike Galbraith, LKML
