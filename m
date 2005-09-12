From: Linus Torvalds <torvalds@osdl.org>
Date: Mon, 12 Sep 2005 14:49:56 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <Pine.LNX.4.58.0509120746550.3242@g5.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Mon, 12 Sep 2005, Keith Owens wrote:
> 
> Or does something that stops the scheduler running on other cpus, which
> ia64 does.  You are probably unaware that MCA/INIT cause the _entire_
> system to rendezvous.  All cpus are driven into MCA/INIT code, not just
> the current cpu.  So the scheduler cannot run on any cpu during
> MCA/INIT.

Ok, I definitely missed that part.

Then, we should add a huge honking comment somewhere there, to make it 
obvious that those functions are only usable within that context. And 
probably make them #ifdef CONFIG_IA64 too (and hide them in shame at the 
bottom of the file), so that nobody can ever use them for anything else. 

For example, right now the thing says "this function must be called with 
interrupts disabled". That's a piece of crap. If it had said "this 
function must be called only when all CPU's in the system have been 
stopped", that's something else altogether.

		Linus
