From: Yaroslav Halchenko <yoh@onerussian.com>
Date: Mon, 24 Nov 2003 21:44:20 +0000
Subject: Re: weird speed problem
Message-Id: <marc-linux-ia64-106971091201773@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106957761119369@msgid-missing>
In-Reply-To: <marc-linux-ia64-106957761119369@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thank you guys for ideas and tools!

I will look into them... 
For now I've just ran nbench tools to estimate performance... results
are not that rudiculosly bad, so probably I messed up something with
that my small programm...

If you're interested here are some results of comparison
under 
Baseline (LINUX)    : AMD K6/233*, 512 KB L2-cache, gcc 2.7.2.3, libc-5.4.38
---------------------------
Itanium (rx2600 HP server) 
dual of
vendor     : GenuineIntel
arch       : IA-64
family     : Itanium 2
model      : 0
revision   : 7
archrev    : 0
features   : branchlong
cpu number : 0
cpu regs   : 4
cpu MHz    : 900.000000
itc MHz    : 900.000000
BogoMIPS   : 1346.37
results:

MEMORY INDEX        : 3.124
INTEGER INDEX       : 5.144
FLOATING-POINT INDEX: 7.387


opteron dual of
processor       : 1
vendor_id       : AuthenticAMD
cpu family      : 15
model           : 5
model name      : AMD Opteron(tm) Processor 240
stepping        : 1
cpu MHz         : 1403.219
cache size      : 1024 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush mmx fxsr sse sse2 syscall mmxext lm 3dnowext
3dnow
bogomips        : 2804.94

results in 32bits:
MEMORY INDEX        : 9.101
INTEGER INDEX       : 7.426
FLOATING-POINT INDEX: 14.897

results in 64bits:
MEMORY INDEX        : 9.839
INTEGER INDEX       : 9.880
FLOATING-POINT INDEX: 13.895


which is a bit confusing as for floating-point for opterons....


On Mon, Nov 24, 2003 at 01:21:39PM -0800, David Mosberger wrote:
> >>>>> On Mon, 24 Nov 2003 12:00:09 -0800, "Luck, Tony" <tony.luck@intel.com> said:
> 
>   Tony> You may be able to determine whether this is your problem by
>   Tony> using Stephane's "pfmon" tool to count cache misses at various
>   Tony> levels of the cache hierarchy, and comparing these numbers
>   Tony> from run to run.  If you see wildly varying numbers, and your
>   Tony> system is idle apart from the test program, then lack of cache
>   Tony> colouring is probably the issue.
> 
> Sounds like a good suggestion to me, but before doing that, I'd
> recommend to collect a simple profile.  Just to see if anything
> obvious is going wrong (like unaligned accesses, lots of fpswa faults,
> or similar).
> 
> Hans's qprof tool might come in handy for that:
> 
>   http://www.hpl.hp.com/research/linux/qprof/
> 
> Also, I have a not-yet-released tool which can collect call-counts
> (similar to gprof, but without recompilation).  I hope to release it
> sometime next week or shortly thereafter, but if someone screams
> loudly enough, I might consider making a quick but totally unsupported
> snapshot of what I have.
> 
> 	--david
                                  .-.
=------------------------------   /v\  ----------------------------Keep in touch                    // \\     (yoh@|www.)onerussian.com
Yaroslav Halchenko              /(   )\               ICQ#: 60653192
                   Linux User    ^^-^^    [175555]
             Key  http://www.onerussian.com/gpg-yoh.asc
GPG fingerprint   3BB6 E124 0643 A615 6F00  6854 8D11 4563 75C0 24C8

