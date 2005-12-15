From: Benjamin LaHaise <bcrl@kvack.org>
Date: Thu, 15 Dec 2005 14:28:01 +0000
Subject: Re: 2.6.15-rc5-mm2 can't boot on ia64 due to changing on_each_cpu().
Message-Id: <20051215142801.GA2444@kvack.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051215103344.241C.Y-GOTO@jp.fujitsu.com> <20051214185658.7a60aa07.akpm@osdl.org> <20051215030040.GA28660@kvack.org> <43A0FE0D.6030100@jp.fujitsu.com>
In-Reply-To: <43A0FE0D.6030100@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com

On Thu, Dec 15, 2005 at 02:24:29PM +0900, Kenji Kaneshige wrote:
> How about this?

Excellent!  Thanks Kenji.  Tony, are you okay with this patch going in?

		-ben
