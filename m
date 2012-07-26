From: Peter Chubb <peter.chubb@nicta.com.au>
Date: Thu, 26 Jul 2012 22:17:50 +0000
Subject: Re: [PATCH] debug: Do not permit CONFIG_DEBUG_STACK_USAGE=y on IA64 or PARISC
Message-Id: <w4k3xq9ng1.wl%peter@chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <4a613b26cc402fb3ed8130cd07a37e76f4c133ef.1342634029.git.tony.luck@intel.com>
	<20120725074501.GB27950@gmail.com>
	<1343203348.3139.16.camel@dabdike>
	<20120726120122.GA24672@gmail.com>
In-Reply-To: <20120726120122.GA24672@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Helge Deller <deller@gmx.de>, linux-parisc@vger.kernel.org, linux-ia64@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

>>>>> "Ingo" = Ingo Molnar <mingo@kernel.org> writes:

Ingo> * James Bottomley <James.Bottomley@HansenPartnership.com> wrote:
>> Since the problem is an invalid assumption about how the stack
>> grows, why not just condition it on that.  We actually have a
>> config option for this: CONFIG_STACK_GROWSUP.  But for some reason
>> ia64 doesn't define this, why not, Tony?  It looks deliberate
>> because you have replaced a lot of
>> 
>> #ifdef CONFIG_STACK_GROWSUP
>> 
>> with
>> 
>> #if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
>> 
>> but not all of them.

Ingo> Yes, that's another possible solution, assuming that it's really
Ingo> only about the up/down difference.

Ingo> Thanks,

IA64 has two stacks -- the standard one, that grows down, and the
register stack engine backing store, that grows up.  The usual
mechanisms for stack growth are used, so only some of the bits
predicated on `STACK_GROWSUP' are useful.

Peter C
--
Dr Peter Chubb				        peter.chubb AT nicta.com.au
http://www.ssrg.nicta.com.au          Software Systems Research Group/NICTA
