From: "Yu, Luming" <luming.yu@intel.com>
Date: Thu, 20 May 2004 03:45:09 +0000
Subject: RE: [PATCH]   (was RE: IA64 test report:Umount cdrom oops : 2.6.6 /Lion 2004-5-13: 8/10  pass)
Message-Id: <3ACA40606221794F80A5670F0AF15F84046233F4@PDSMSX403.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F840462309C@PDSMSX403.ccr.corp.intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F840462309C@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>
>>>>>> On Thu, 20 May 2004 10:30:09 +0800, "Yu, Luming" 
><luming.yu@intel.com> said:
>
>  Luming> Hmm, maybe its memory ordering issue here.
>  >>  How interesting.  Do you have CONFIG_PREEMPT enabled?
>
>  Luming> grep -i preempt include/linux/autoconf.h
>  Luming> #undef CONFIG_PREEMPT
>
>It can't be a memory-ordering issue then.  Memory certainly is 
>guaranteed
>to be coherent...

I call it memory-ordering issue, because the problem is that 
lock_kernel increment the lock_depth,  but the subsequent 
unlock_kernel somehow get the old value of that lock_depth.
Then BUG_ON will be triggered. 

After reading the disassembly code, I got the impression
that gcc seems to generate the correct code. But
I'm not sure there is NO memory ordering issue in the
gcc-generated code.

>
>I agree with Matthew then: most likely a compiler issue.  Especially
>since nobody else has reported a similar problem.
>

I agree, if compiler can assure it. This is 4 way 800M Itanium, Lion.

Thanks,
Luming 


