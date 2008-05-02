From: Andi Kleen <andi@firstfloor.org>
Date: Fri, 02 May 2008 17:45:55 +0000
Subject: Re: [PATCH 3/3] ia64: Call migration code on correctable errors v2
Message-Id: <87fxt0vbu4.fsf@basil.nowhere.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502004425.GD12006@sgi.com>
In-Reply-To: <20080502004425.GD12006@sgi.com> (Russ Anderson's message of "Thu, 1 May 2008 19:44:25 -0500")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Christoph Lameter <clameter@sgi.com>

Russ Anderson <rja@sgi.com> writes:

> Migrate data off pages with correctable memory errors.  This patch is the 
> ia64 specific piece.  It connects the CPE handler to the page migration
> code.  It is implemented as a kernel loadable module, similar to the mca
> recovery code (mca_recovery.ko).  This allows the feature to be turned off
> by uninstalling the module.  Creates /proc/badram to display bad page
> information and free bad pages.

How do you know what pages have excessive errors? And how is excessive defined?
Surely you don't keep  a per page error count? It's unclear from your patch. 

Anyways I don't think this should be ia64 specific, but generic code.

I also have my doubts about making such small code subsystems modules. Modules
always get rounded to pages so it ultimatively just wastes memory.

-Andi
