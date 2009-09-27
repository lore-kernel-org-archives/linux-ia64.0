From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 27 Sep 2009 00:08:46 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <alpine.LFD.2.01.0909261704220.3303@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Sat, 26 Sep 2009, Linus Torvalds wrote:
> 
>  - spinlock:
> 
> 	fetchadd4.acq r1=[p],1
> 	target = (r1 & 32767);

Oh, and this should have been "target = (r1+1) & 32767", since fetchadd 
will return the old value (I think), not the incremented one.

In general, that whole thing was meant to be more pseudo-code than 
anything directly working. As if that wasn't obvious from me freely mixing 
assembler code ('fetchadd4.acq' and 'st2.rel') with C-like pseudo-code.

But I checked, and 'st2.rel' seems to be a valid opcode, and the memory 
ordering constraints seems to be ok with mixing differently sized 
operations on the same memory. So I think my basic algorithm of 
using fetchadd4 should be ok.

			Linus
