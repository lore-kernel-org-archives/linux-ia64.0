From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Thu, 18 Aug 2005 23:58:16 +0000
Subject: Re: Simulator bootloader fails with gcc 4
Message-Id: <17157.8344.318983.87573@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050720053139.GC13188@cse.unsw.EDU.AU>
In-Reply-To: <20050720053139.GC13188@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Stephane" = Stephane Eranian <eranian@hpl.hp.com> writes:

Stephane> On Fri, Aug 19, 2005 at 09:14:56AM +1000, Peter Chubb wrote:
>> >>>>> "Stephane" = Stephane Eranian <eranian@hpl.hp.com> writes:
>> 
Stephane> The simulator is not using the regular memcpy() routine it
Stephane> has its own custom routine (which is not named memcpy).
>>  This is a stupid suggestion, but...
>> 
>> Can you try recompiling the simulator with gcc 4.0, and see if the
>> problem is still there?  If a gcc 4.0-compiled simulator that fixes
>> the problem, and still allows booting of kernels compiled with icc,
>> gcc-2.96, etc., etc., can be released, then we're done.
>> 
Stephane> Does this problem happen with the x86 and/or ia64 ski
Stephane> version when bootloader is compiled with gcc-4.0?

IA64 and i386.

Stephane> I can certainly try to compile ski with gcc-4.0. Could
Stephane> anyone of you send me his .config file to make sure we have
Stephane> comparable kernels.

It's the arch/ia64/confis/sim_defconfig file in any recent kernel.

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
