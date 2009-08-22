From: Andrew Morton <akpm@linux-foundation.org>
Date: Sat, 22 Aug 2009 00:17:38 +0000
Subject: Re: [Patch 1/8] kexec: allow to shrink reserved memory
Message-Id: <20090821171738.304fe91e.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090821065637.4855.32234.sendpatchset@localhost.localdomain>
	<20090821065650.4855.53279.sendpatchset@localhost.localdomain>
In-Reply-To: <20090821065650.4855.53279.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, nhorman@redhat.com, ebiederm@xmission.com, andi@firstfloor.org, mingo@elte.hu, amwang@redhat.com, bernhard.walle@gmx.de, fenghua.yu@intel.com, kamezawa.hiroyu@jp.fujitsu.com, avorontsov@ru.mvista.com

On Fri, 21 Aug 2009 02:54:25 -0400
Amerigo Wang <amwang@redhat.com> wrote:

> +size_t get_crash_memory_size(void)
> +int shrink_crash_memory(unsigned long new_size)

These aren't particualrly well-chosen global identifiers.  It would be
better if they were called crash_*() or kexec_*(), to make it clear
which subsystem they belong to.

