From: Benjamin LaHaise <bcrl@kvack.org>
Date: Thu, 15 Dec 2005 03:00:40 +0000
Subject: Re: 2.6.15-rc5-mm2 can't boot on ia64 due to changing on_each_cpu().
Message-Id: <20051215030040.GA28660@kvack.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051215103344.241C.Y-GOTO@jp.fujitsu.com> <20051214185658.7a60aa07.akpm@osdl.org>
In-Reply-To: <20051214185658.7a60aa07.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com

On Wed, Dec 14, 2005 at 06:56:58PM -0800, Andrew Morton wrote:
> Thanks.  I'll drop it.

Please don't.  Fix ia64's brain damage instead.  Function pointers 
should not be cast, period.

		-ben
-- 
"You know, I've seen some crystals do some pretty trippy shit, man."
Don't Email: <dont@kvack.org>.
