From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 05 Apr 2006 04:31:35 +0000
Subject: Re: [Fastboot] [PATCH] kexec on ia64
Message-Id: <20060405133135.fda5bd82.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <08B1877B2880CE42811294894F33AD5C053A82@pdsmsx411.ccr.corp.intel.com>
	<20060405101243.e3e4f772.kamezawa.hiroyu@jp.fujitsu.com>
	<m1vetoivn6.fsf@ebiederm.dsl.xmission.com>
In-Reply-To: <m1vetoivn6.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: nanhai.zou@intel.com, khalid_aziz@hp.com, linux-kernel@vger.kernel.org, fastboot@lists.osdl.org, linux-ia64@vger.kernel.org

On Tue, 04 Apr 2006 20:49:49 -0600
ebiederm@xmission.com (Eric W. Biederman) wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> 
> > Hi, I have a question about kexec/kdump.
> >
> > How does kdump know memory layout (of old kernel) now ?
> >
> > I'm working for memory hotplug. When memory is hot-added, memory layout changes.
> > But I think there is no code to manage memory layout information of added
> > memory.
> 
> It is passed from one kernel to another, and it is memorized when you load
> the crash dump kernel.  If your memory layout changes you need to reload
> the crash dump kernel from user space with the appropriate hotplug script.  
> 
> Unless this happens often it shouldn't be a problem. 
> 

> And yes this does leave a small race during which kexec on panic won't
> work.

Hmm.. Okay. 
Before reloading kdump kernel, kdump continues to use old information.
(when adding, it's not be big problem.)

Thank you.
- Kame

