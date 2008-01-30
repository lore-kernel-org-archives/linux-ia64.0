From: Mike Travis <travis@sgi.com>
Date: Wed, 30 Jan 2008 19:59:46 +0000
Subject: Re: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <47A0D732.9070201@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0801301622460.11859@vixen.sonytel.be>
In-Reply-To: <Pine.LNX.4.64.0801301622460.11859@vixen.sonytel.be>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ingo Molnar wrote:
> * Ingo Molnar <mingo@elte.hu> wrote:
> 
>>> Some place in there.  The CONFIG_SMP=n path in ia64 makes quite 
>>> radical changes ... rather than putting all the per-cpu stuff into 
>>> the top 64K of address space and providing a per-cpu TLB mapping for 
>>> that range to a different physical address ... it just makes all the 
>>> per-cpu stuff link as ordinary variables in .data.  The error 
>>> messages indicate that some of the new code is unaware of this.
>> ah, that was the vital clue. The patch below makes the small memory 
>> model only defined on SMP, and makes the config build/link fine here. 
>> Does this build and boot on your box?
> 
> if this works for you then could you please send me your Acked-by as 
> well, for this and the other ia64 changes, so that we can send these to 
> Linus ASAP?
> 
> 	Ingo

Thanks both of you for the help.  I even tried natively compiling on
an Altix (ia64) server and the same error occurred in psmouse-base.c
and md.c.  So both gcc's have the same problem:


6> gcc --version
gcc (GCC) 4.2.0
Copyright (C) 2007 Free Software Foundation, Inc.

 81> ia64-linux-gnu-gcc --version
ia64-linux-gnu-gcc (GCC) 4.2.3 20071123 (prerelease) (Debian 4.2.2-4)

