From: Minchan Kim <minchan@kernel.org>
Date: Wed, 12 Sep 2012 06:17:47 +0000
Subject: Re: [RFC v8 PATCH 00/20] memory-hotplug: hot-remove physical memory
Message-Id: <20120912061747.GA31798@bbox>
List-Id: <linux-ia64.vger.kernel.org>
References: <1346148027-24468-1-git-send-email-wency@cn.fujitsu.com>
 <20120831134956.fec0f681.akpm@linux-foundation.org>
 <504D467D.2080201@jp.fujitsu.com>
 <504D4A08.7090602@cn.fujitsu.com>
 <20120910135213.GA1550@dhcp-192-168-178-175.profitbricks.localdomain>
 <CAAV+Mu7YWRWnxt78F4ZDMrrUsWB=n-_qkYOcQT7WQ2HwP89Obw@mail.gmail.com>
 <20120911012345.GD14205@bbox>
 <CAAV+Mu4hb0qbW2Ry6w5FAGUM06puDH0v_H-jr584-G9CzJqSGw@mail.gmail.com>
In-Reply-To: <CAAV+Mu4hb0qbW2Ry6w5FAGUM06puDH0v_H-jr584-G9CzJqSGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jerry <uulinux@gmail.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, kosaki.motohiro@jp.fujitsu.com

On Tue, Sep 11, 2012 at 01:18:24PM +0800, Jerry wrote:
> Hi Kim,
> 
> Thank you for your kindness. Let me clarify this:
> 
> On ARM architecture, there are 32 bits physical addresses space. However,
> the addresses space is divided into 8 banks normally. Each bank
> disabled/enabled by a chip selector signal. In my platform, bank0 connects
> a DDR chip, and bank1 also connects another DDR chip. And each DDR chip
> whose capability is 512MB is integrated into the main board. So, it could
> not be removed by hand. We can disable/enable each bank by peripheral
> device controller registers.
> 
> When system enter suspend state, if all the pages allocated could be
> migrated to one bank, there are no valid data in the another bank. In this
> time, I could disable the free bank. It isn't necessary to provided power
> to this chip in the suspend state. When system resume, I just need to
> enable it again.
> 

Yes. I already know it and other trials for that a few years ago[1].
A few years ago, I investigated the benefit between power consumption
benefit during suspend VS start-up latency of resume and
power consumption cost of migration(page migration and IO write for
migration) and concluded normally the gain is not big. :)
The situation could be changed these days as workload are changing
but I'm skeptical about that approach, still.

Anyway, it's my private thought so you don't need to care about that.
If you are ready to submit the patchset, please send out.

1. http://lwn.net/Articles/478049/

Thanks.

- 
Kind regards,
Minchan Kim
