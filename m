From: Michal Hocko <mhocko@suse.cz>
Date: Thu, 17 Jan 2013 13:05:09 +0000
Subject: Re: [PATCH v3 1/2] memory-hotplug: introduce CONFIG_HAVE_BOOTMEM_INFO_NODE and revert register_page_
Message-Id: <20130117130509.GE20538@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1358324059-9608-1-git-send-email-linfeng@cn.fujitsu.com>
 <1358324059-9608-2-git-send-email-linfeng@cn.fujitsu.com>
 <20130116141436.GE343@dhcp22.suse.cz>
 <50F7D456.9000904@cn.fujitsu.com>
In-Reply-To: <50F7D456.9000904@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, jbeulich@suse.com, dhowells@redhat.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, paul.gortmaker@windriver.com, laijs@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, minchan@kernel.org, aquini@redhat.com, jiang.liu@huawei.com, tony.luck@intel.com, fenghua.yu@intel.com, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, michael@ellerman.id.au, gerald.schaefer@de.ibm.com, gregkh@linuxfoundation.org, x86@kernel.org, linux390@de.ibm.com, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, tangchen@cn.fujitsu.com

On Thu 17-01-13 18:37:10, Lin Feng wrote:
[...]
> > I am still not sure I understand the relation to MEMORY_HOTREMOVE.
> > Is register_page_bootmem_info_node required/helpful even if
> > !CONFIG_MEMORY_HOTREMOVE?
> From old kenrel's view register_page_bootmem_info_node() is defined in 
> CONFIG_MEMORY_HOTPLUG_SPARSE, it registers some info for 
> memory hotplug/remove. If we don't use MEMORY_HOTPLUG feature, this
> function is empty, we don't need the info at all.
> So this info is not required/helpful if !CONFIG_MEMORY_HOTREMOVE.

OK, then I suggest moving it under CONFIG_MEMORY_HOTREMOVE guards rather
than CONFIG_MEMORY_HOTPLUG.

> > Also, now that I am thinking about that more, maybe it would
> > be cleaner to put the select into arch/x86/Kconfig and do it
> > same as ARCH_ENABLE_MEMORY_{HOTPLUG,HOTREMOVE} (and name it
> > ARCH_HAVE_BOOTMEM_INFO_NODE).
> > 
> Maybe put it in mm/Kconfig is a better choice, because if one day
> someone implements the register_page_bootmem_info_node() for other
> archs they will get some clues here, that's it has been implemented on
> x86_64.
> But I'm not so sure...

My understanding is that doing that in arch code is more appropriate
because it makes the generic code less complicated. But I do not have
any strong opinion on that. Looking at other ARCH_ENABLE_MEMORY_HOTPLUG
and others suggests that we should be consistent with that.

Thanks!
-- 
Michal Hocko
SUSE Labs
