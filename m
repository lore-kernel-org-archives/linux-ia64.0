From: Andrew Morton <akpm@osdl.org>
Date: Thu, 09 Mar 2006 12:01:04 +0000
Subject: Re: [PATCH: 012/017](RFC) Memory hotplug for new nodes v.3.
Message-Id: <20060309040104.6e6f5ccd.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060308213410.003A.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060308213410.003A.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: tony.luck@intel.com, ak@suse.de, jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
>
> In current code, zonelist is considered to be build once, no modification.
>  But MemoryHotplug can add new zone/pgdat. It must be updated.
> 
>  This patch modifies build_all_zonelists(). 
>  By this, build_all_zonelist() can reconfig pgdat's zonelists.
> 
>  To update them safety, this patch use stop_machine_run().

Yup, that's a good way of doing it.
