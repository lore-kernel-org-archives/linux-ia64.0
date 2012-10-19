From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 19 Oct 2012 18:33:17 +0000
Subject: Re: [PATCH 1/10] memory-hotplug : check whether memory is offline or not when removing memory
Message-Id: <CAHGf_=q=Agidyj_j6jhBdhNmJBy2u1dP+UMAoXbM=_=DyZJs_w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <506E43E0.70507@jp.fujitsu.com> <506E451E.1050403@jp.fujitsu.com>
 <CAHGf_=rVDm-JygjPoLHbmF28Dgd52HFc4-b5KCxhEieG60okuw@mail.gmail.com>
 <50812F13.20503@cn.fujitsu.com> <5081609C.9080702@gmail.com>
In-Reply-To: <5081609C.9080702@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wen Congyang <wencongyang@gmail.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org

> I think it again, and found that this check is necessary. Because we only
> lock memory hotplug when offlining pages. Here is the steps to offline and
> remove memory:
>
> 1. lock memory hotplug
> 2. offline a memory section
> 3. unlock memory hotplug
> 4. repeat 1-3 to offline all memory sections
> 5. lock memory hotplug
> 6. remove memory
> 7. unlock memory hotplug
>
> All memory sections must be offlined before removing memory. But we don't
> hold
> the lock in the whole operation. So we should check whether all memory
> sections
> are offlined before step6.

You should describe the race scenario in the patch description. OK?
