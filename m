From: Keith Owens <kaos@sgi.com>
Date: Mon, 12 Sep 2005 15:13:30 +0000
Subject: Re: git pull on ia64 linux tree
Message-Id: <9511.1126538010@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 12 Sep 2005 07:49:56 -0700 (PDT), 
Linus Torvalds <torvalds@osdl.org> wrote:
>
>
>On Mon, 12 Sep 2005, Keith Owens wrote:
>> 
>> Or does something that stops the scheduler running on other cpus, which
>> ia64 does.  You are probably unaware that MCA/INIT cause the _entire_
>> system to rendezvous.  All cpus are driven into MCA/INIT code, not just
>> the current cpu.  So the scheduler cannot run on any cpu during
>> MCA/INIT.
>
>Ok, I definitely missed that part.
>
>Then, we should add a huge honking comment somewhere there, to make it 
>obvious that those functions are only usable within that context. And 
>probably make them #ifdef CONFIG_IA64 too (and hide them in shame at the 
>bottom of the file), so that nobody can ever use them for anything else. 
>
>For example, right now the thing says "this function must be called with 
>interrupts disabled". That's a piece of crap. If it had said "this 
>function must be called only when all CPU's in the system have been 
>stopped", that's something else altogether.

I'll give you that one, it should have said "interrupts disabled on all
cpus", and do a patch against git tommorrow.  Then I can get back to
taking my seriously damaging drugs[1], AKA working on IA64 recovery.

BTW Linus, are you aware that your mailer is putting spaces at the end
of almost every text line?

[1] http://marc.theaimsgroup.com/?l=linux-ia64&m2649624832016&w=2

