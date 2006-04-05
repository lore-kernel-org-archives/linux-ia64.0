From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 05 Apr 2006 01:27:33 +0000
Subject: Re: [Fastboot] [PATCH] kexec on ia64
Message-Id: <20060405102733.eabc00fe.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <08B1877B2880CE42811294894F33AD5C053A85@pdsmsx411.ccr.corp.intel.com>
In-Reply-To: <08B1877B2880CE42811294894F33AD5C053A85@pdsmsx411.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zou, Nanhai" <nanhai.zou@intel.com>
Cc: ebiederm@xmission.com, khalid_aziz@hp.com, linux-kernel@vger.kernel.org, fastboot@lists.osdl.org, linux-ia64@vger.kernel.org

On Wed, 5 Apr 2006 09:13:36 +0800
"Zou, Nanhai" <nanhai.zou@intel.com> wrote:
> > I'm working for memory hotplug. When memory is hot-added, memory layout
> > changes.
> > But I think there is no code to manage memory layout information of added memory.
> > 
>  It reads memory layout from /proc/iomem...,
>  If memory is hotpluged, I think we need a reload of kdump.
> 
If /proc/iomem is updated at hotplug event (this is not updated now),
is there no problem ?

calling insert_resource like  efi_initialize_iomem_resources() is good ?

-Kame

