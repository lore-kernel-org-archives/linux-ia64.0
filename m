From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Date: Fri, 30 May 2014 02:47:44 +0000
Subject: Re: [RFT PATCH -next v2] [BUGFIX] kprobes: Fix "Failed to find blacklist" error on ia64 and ppc64
Message-Id: <5387F150.5000307@hitachi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5383249A.6060407@in.ibm.com> <20140527063121.4399.38014.stgit@ltc230.yrl.intra.hitachi.co.jp> <538786D8.1070303@in.ibm.com>
In-Reply-To: <538786D8.1070303@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Suzuki K. Poulose" <suzuki@in.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Tony Luck <tony.luck@gmail.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-ia64@vger.kernel.org, sparse@chrisli.org, "H. Peter Anvin" <hpa@zytor.com>, akataria@vmware.com, linux-tip-commits@vger.kernel.org, anil.s.keshavamurthy@intel.com, Ingo Molnar <mingo@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Arnd Bergmann <arnd@arndb.de>, Rusty Russell <rusty@rustcorp.com.au>, Chris Wright <chrisw@sous-sol.org>, yrl.pp-manager.tt@hitachi.com, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Kevin Hao <haokexin@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, rdunlap@infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dl9pf@gmx.de, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

(2014/05/30 4:13), Suzuki K. Poulose wrote:
>> @@ -2042,7 +2043,8 @@ static int __init populate_kprobe_blacklist(unsigned long *start,
>>  	unsigned long offset = 0, size = 0;
>>  
>>  	for (iter = start; iter < end; iter++) {
>> -		if (!kallsyms_lookup_size_offset(*iter, &size, &offset)) {
>> +		if (!kallsyms_lookup_size_offset(function_entry(*iter),
>> +						 &size, &offset)) {
> 
> On powerpc we will be able to resolve the *iter to func_descr and won't
> get the below error with/without this patch. So we have to actually
> verify the kprobe_blacklist contents to make sure everything is alright.
> 
>>  			pr_err("Failed to find blacklist %p\n", (void *)*iter);
>>  			continue;
>>  		}
>>
> 
> There is a bug here.
> You need to set the ent->start using the function_entry(*iter) and not
> *iter. Or else you just avoid the 'Warning' and still have an invalid
> black list. As shown below :
> 
>     2e:mon> ls kprobe_blacklist
>     kprobe_blacklist: c00000000104dad0
>     2e:mon> d c00000000104dad0 10
>     c00000000104dad0: c0000003aff800a0 c0000003aff809a0
>     2e:mon> d c0000003aff800a0 20 (struct kprobe_blacklist *)
>     c0000003aff800a0: c0000003aff800c0 c00000000104dad0
>     c0000003aff800b0: c0000000010ef138 c0000000010ef188
>                       start ^^         end ^^
>     2e:mon> la c0000000010ef138 (start)
>     c0000000010ef138: notify_die+0x0/0x10 <- still points to the
> function descriptor
>     2e:mon> la c0000000010ef188 (end)
>     c0000000010ef188: __blocking_notifier_call_chain+0x0/0x10
> 
> 
> Following patch fixes the issue, with the patch :
> 
> 1:mon> ls kprobe_blacklist
> kprobe_blacklist: c00000000104dad0
> 1:mon> d c00000000104dad0 10
> c00000000104dad0: c0000003ae1a00a0 c0000003ae1a09a0
> 1:mon> d c0000003ae1a00a0 20 (struct kprobe_blacklist *)
> c0000003ae1a00a0: c0000003ae1a00c0 c00000000104dad0
> c0000003ae1a00b0: c0000000000b14d0 c0000000000b1520
>                       start ^^         end ^^
> 1:mon> la c0000000000b14d0
> c0000000000b14d0: .notify_die+0x0/0x50
> 1:mon> la c0000000000b1520
> c0000000000b1520: .atomic_notifier_chain_register+0x0/0xa0
> 
> 1:mon> di c0000000000b14d0 10 (.notify_die)
> c0000000000b14d0  7c0802a6	mflr	r0
> c0000000000b14d4  7c691b78	mr	r9,r3
> 
> commit ed51674aca8e0496641f565421ab6691a873e80a
> Author: Suzuki K. Poulose <suzuki@in.ibm.com>
> Date:   Fri May 30 00:23:01 2014 +0530
> 
> diff --git a/kernel/kprobes.c b/kernel/kprobes.c
> index 3859c88..b81d626 100644
> --- a/kernel/kprobes.c
> +++ b/kernel/kprobes.c
> @@ -2043,7 +2043,8 @@ static int __init
> populate_kprobe_blacklist(unsigned long *start,
>         unsigned long offset = 0, size = 0;
> 
>         for (iter = start; iter < end; iter++) {
> -               if (!kallsyms_lookup_size_offset(function_entry(*iter),
> +               unsigned long entry = function_entry(*iter);
> +               if (!kallsyms_lookup_size_offset(entry,
>                                                  &size, &offset)) {
>                         pr_err("Failed to find blacklist %p\n", (void
> *)*iter);
>                         continue;
> @@ -2052,8 +2053,8 @@ static int __init
> populate_kprobe_blacklist(unsigned long *start,
>                 ent = kmalloc(sizeof(*ent), GFP_KERNEL);
>                 if (!ent)
>                         return -ENOMEM;
> -               ent->start_addr = *iter;
> -               ent->end_addr = *iter + size;
> +               ent->start_addr = entry;
> +               ent->end_addr = entry + size;

Oops! right, I missed it :(
I'll update the patch including your fix and signed-off-by.

thank you!


-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Research Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com


