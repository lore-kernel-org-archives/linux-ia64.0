From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 26 May 2006 09:06:40 +0000
Subject: Re: [RFC][PATCH] ia64 node hotplug -- cpu - node relationship fix
Message-Id: <20060526180640.76849095.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060526175622.13057d7e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060526175622.13057d7e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, linux-ia64@vger.kernel.org, ashok.raj@intel.com, steiner@sgi.com, tony.luck@intel.com

On Fri, 26 May 2006 17:56:22 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> current -mm tree includes node-hotplug codes.
> 
> But by following reason , ia64's node-hotplug doesn't work well now.
> 
> Following patch will fix it. I'd like to post this patch against next -mm.
> Feedbacks are welcome.
> 
> 1. empty-node-fix : avoid creating empty node
>    SRAT's enable bit just shows 'you can read this entry'. But the kernel know
							    ^^^^
                                                             And

-Kame

