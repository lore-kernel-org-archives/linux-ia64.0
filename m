From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 01 Mar 2006 20:09:53 +0000
Subject: RE: gas is overly conservative with itc instruction
Message-Id: <200603012009.k21K9rg31804@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB506C07A07@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB506C07A07@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

John S. Worley wrote on Wednesday, March 01, 2006 11:29 AM
>     Have you tried explicit bundling? I wouldn't rely on
> the assembler to bundle critical code like this, and the
> performance is worth the extra effort.

I suppose so. And just realize that it might be because of gcc assembler
bent backwards for sloppy kernel developer.  If we follow the software
developer manual to the teeth, the code in vhpt_miss isn't strictly
correct:

(p10)   itc.i r18                     // insert the instruction TLB entry
(p11)   itc.d r18                     // insert the data TLB entry
(p6)    br.cond.spnt.many page_fault  // handle bad address/page not present (page fault)

It misses stop bits in the source for both itc instructions.  And gas
silently fixed up the bug and forced stop bit right before insn, except
it wasn't doing a good job at collapsing multiple stop. Manually adding
stop bits to it produces desired bundling.

Even though p10 and p11 are mutually exclusive, there are no m-m-stop-i
bundle template and itc can be only issued to one of the 4 memory port,
so adding a stop bit in between won't matter anyway.

HJ, nevermind, I think we are OK.


- Ken

