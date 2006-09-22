From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 22 Sep 2006 02:46:23 +0000
Subject: Re: [BUGFIX] [PATCH] [IA64] node hotplug : fixup cpu-to-node
Message-Id: <20060922114623.321972b5.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060922100721.4714a8ed.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060922100721.4714a8ed.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com, akpm@osdl.org

On Fri, 22 Sep 2006 10:07:21 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

>
> =
> When a cpu is not tied to its node at(before) cpu-onlining, the system panics.
> node_to_cpu_mask[] should be set to valid value before notifier of CPU_ONLINE
> is called.(if not, the system panics.)
> 

Sorry, please ignore this patch. I noticed cpu <-> node relation should be fixed
before CPU_UP_PREPARE. I'll post another one sonn.

-Kame

