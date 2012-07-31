From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Date: Tue, 31 Jul 2012 12:40:00 +0000
Subject: Re: [RFC PATCH v5 12/19] memory-hotplug: introduce new function arch_remove_memory()
Message-Id: <20120731144000.33fd4a0a@thinkpad>
List-Id: <linux-ia64.vger.kernel.org>
References: <50126B83.3050201@cn.fujitsu.com>
	<50126E2F.8010301@cn.fujitsu.com>
	<20120730102305.GB3631@osiris.boeblingen.de.ibm.com>
	<50166379.4090305@cn.fujitsu.com>
In-Reply-To: <50166379.4090305@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>

On Mon, 30 Jul 2012 18:35:37 +0800
Wen Congyang <wency@cn.fujitsu.com> wrote:

> At 07/30/2012 06:23 PM, Heiko Carstens Wrote:
> > On Fri, Jul 27, 2012 at 06:32:15PM +0800, Wen Congyang wrote:
> >> We don't call __add_pages() directly in the function add_memory()
> >> because some other architecture related things need to be done
> >> before or after calling __add_pages(). So we should introduce
> >> a new function arch_remove_memory() to revert the things
> >> done in arch_add_memory().
> >>
> >> Note: the function for s390 is not implemented(I don't know how to
> >> implement it for s390).
> > 
> > There is no hardware or firmware interface which could trigger a
> > hot memory remove on s390. So there is nothing that needs to be
> > implemented.
> 
> Thanks for providing this information.
> 
> According to this, arch_remove_memory() for s390 can just return
> -EBUSY.

Yes, but there is a prototype mismatch for arch_remove_memory() on s390
and also other architectures (u64 vs. unsigned long).

arch/s390/mm/init.c:262: error: conflicting types for
‘arch_remove_memory’ include/linux/memory_hotplug.h:88: error: previous
declaration of ‘arch_remove_memory’ was here

In memory_hotplug.h you have:
extern int arch_remove_memory(unsigned long start, unsigned long size);

On all archs other than x86 you have:
int arch_remove_memory(u64 start, u64 size)

