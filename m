From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 05 Apr 2006 02:49:49 +0000
Subject: Re: [Fastboot] [PATCH] kexec on ia64
Message-Id: <m1vetoivn6.fsf@ebiederm.dsl.xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <08B1877B2880CE42811294894F33AD5C053A82@pdsmsx411.ccr.corp.intel.com>
	<20060405101243.e3e4f772.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060405101243.e3e4f772.kamezawa.hiroyu@jp.fujitsu.com> (KAMEZAWA
 Hiroyuki's message of "Wed, 5 Apr 2006 10:12:43 +0900")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Zou, Nanhai" <nanhai.zou@intel.com>, khalid_aziz@hp.com, linux-kernel@vger.kernel.org, fastboot@lists.osdl.org, linux-ia64@vger.kernel.org

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> Hi, I have a question about kexec/kdump.
>
> How does kdump know memory layout (of old kernel) now ?
>
> I'm working for memory hotplug. When memory is hot-added, memory layout changes.
> But I think there is no code to manage memory layout information of added
> memory.

It is passed from one kernel to another, and it is memorized when you load
the crash dump kernel.  If your memory layout changes you need to reload
the crash dump kernel from user space with the appropriate hotplug script.  

Unless this happens often it shouldn't be a problem. 

And yes this does leave a small race during which kexec on panic won't
work.

Eric

