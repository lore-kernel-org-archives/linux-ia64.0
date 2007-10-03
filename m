From: Matthew Wilcox <matthew@wil.cx>
Date: Wed, 03 Oct 2007 16:43:13 +0000
Subject: Re: [Question] How to represent SYSTEM_RAM in kerenel/resouce.c
Message-Id: <20071003164313.GH12049@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071003103136.addbe839.kamezawa.hiroyu@jp.fujitsu.com> <1191429433.4939.49.camel@localhost>
In-Reply-To: <1191429433.4939.49.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, andi@firstfloor.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tony.luck@intel.com" <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, pbadari@us.ibm.com, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Wed, Oct 03, 2007 at 09:37:13AM -0700, Dave Hansen wrote:
> I think we should take system ram out of the iomem file, at least.

Rubbish.  iomem is a representation of the physical addresses in the
system as seen from the CPU's perspective.  As I said in my previous
mail in this thread, if you attempt to map a device's BAR over the top
of physical RAM, things will go poorly for you.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
