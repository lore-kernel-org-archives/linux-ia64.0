From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 15 Dec 2005 17:24:03 +0000
Subject: RE: 2.6.15-rc5-mm2 can't boot on ia64 due to changing on_each_cpu().
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0535A4DC@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051215103344.241C.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20051215103344.241C.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin LaHaise <bcrl@kvack.org>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org

> On Thu, Dec 15, 2005 at 02:24:29PM +0900, Kenji Kaneshige wrote:
> > How about this?
> 
> Excellent!  Thanks Kenji.  Tony, are you okay with this patch going in?

It is a bit annoying to have to add an argument that is never
used to local_flush_tlb_all() just to make the compiler make
the right code when we want to use in with on_each_cpu().  But
I don't see a better way.

Acked-by: Tony Luck <tony.luck@intel.com>

-Tony
