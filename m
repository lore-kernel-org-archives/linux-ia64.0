From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 15 Dec 2005 15:41:00 +0000
Subject: Re: 2.6.15-rc5-mm2 can't boot on ia64 due to changing on_each_cpu().
Message-Id: <20051215154100.GB9286@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051215030040.GA28660@kvack.org> <43A0FE0D.6030100@jp.fujitsu.com> <20051215152450.2445.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20051215152450.2445.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, parisc-linux@parisc-linux.org

On Thu, Dec 15, 2005 at 03:34:27PM +0900, Yasunori Goto wrote:
> Thanks! It works!
> 
> BTW, I found same casted function at on_each_cpu() in parisc code.
>  (arch/parisc/kernel/cache.c
>   arch/parisc/kernel/smp.c
>   arch/parisc/mm/init.c)
> 
> Are they also should fixed? 
> I don't have parisc box. So, I don't know there is same trouble on
> parisc box or not, and I can't test it.

Yes, these  will also need to be changed.  Thanks.
