From: Michal Hocko <mhocko@suse.cz>
Date: Wed, 16 Jan 2013 14:15:08 +0000
Subject: Re: [PATCH v3 0/2] memory-hotplug: introduce CONFIG_HAVE_BOOTMEM_INFO_NODE and revert register_page_
Message-Id: <20130116141508.GF343@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1358324059-9608-1-git-send-email-linfeng@cn.fujitsu.com>
In-Reply-To: <1358324059-9608-1-git-send-email-linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, jbeulich@suse.com, dhowells@redhat.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, paul.gortmaker@windriver.com, laijs@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, minchan@kernel.org, aquini@redhat.com, jiang.liu@huawei.com, tony.luck@intel.com, fenghua.yu@intel.com, benh@kernel.crashing.org, paulus@samba.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, michael@ellerman.id.au, gerald.schaefer@de.ibm.com, gregkh@linuxfoundation.org, x86@kernel.org, linux390@de.ibm.com, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, tangchen@cn.fujitsu.com

On Wed 16-01-13 16:14:17, Lin Feng wrote:
[...]
> changeLog v2->v3:
> 1) patch 1/2:
> - Rename the patch title to conform it's content.
> - Update memory_hotplug.h and remove the misleading TODO pointed out by Michal.
> 2) patch 2/2:
> - New added, remove unimplemented functions suggested by Michal.

I think that both patches should be merged into one and put to Andrew's
queue as
memory-hotplug-implement-register_page_bootmem_info_section-of-sparse-vmemmap-fix.patch
rather than a separate patch.
-- 
Michal Hocko
SUSE Labs
