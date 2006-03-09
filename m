From: Andrew Morton <akpm@osdl.org>
Date: Thu, 09 Mar 2006 12:01:00 +0000
Subject: Re: [PATCH: 011/017](RFC) Memory hotplug for new nodes v.3. (start
Message-Id: <20060309040100.0d258a25.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060308213333.0038.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20060308213333.0038.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: tony.luck@intel.com, ak@suse.de, jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
>
>  +EXPORT_SYMBOL(kswapd_run);

Does this need to be exported to modules?

If so, EXPORT_SYMBOL_GPL would be preferred, please.
