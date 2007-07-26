From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 26 Jul 2007 08:27:28 +0000
Subject: Re: [PATCH] flush icache before set_pte on ia64 take3
Message-Id: <20070726172728.f0c6608c.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070726171323.a9c17eda.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070726171323.a9c17eda.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "tony.luck@intel.com" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Zoltan.Menyhart@bull.net, nickpiggin@yahoo.com.au

On Thu, 26 Jul 2007 17:13:23 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>  - lazy_mmu_prot_update() checked pte's executable bit. This was because old
>    Linux's anon page has executable bit. Current kernel doesn't set executable
>    bit on anonymous pages.
> 
Linux's anon page had VM_EXEC bit. Current kernel doesn't set VM_EXEC bit on
anonymous pages. (readable was executable in old days.)

Sorry.. confusing description...
-Kame

