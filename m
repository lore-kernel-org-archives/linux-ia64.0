From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 16 Sep 2004 19:51:02 +0000
Subject: RE: [Patch] Per CPU MCA/INIT data save areas
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02051BAE@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408312112.i7VLCPc9002392@ben.americas.sgi.com>
In-Reply-To: <200408312112.i7VLCPc9002392@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Given that the MCA/INIT paths are (by definition) not hot paths,
>and that CPU regs are a scarce resource, I think there are better 
>places to burn a CPU reg on.
>
>Adding a pointer (or two) to the ia64_mca_tlb_info structure would
>give the necessary functionality. 

I did wonder about using ar.k3 when the TLB error recovery code
was being written, but I figured that David wouldn't give up the
last of the unused kregs for such an obscure and rare usage.

But Keith does have a good point about possibly reclaiming
ar.k5 by replacing it with a percpu variable.

-Tony
