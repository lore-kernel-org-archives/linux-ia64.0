From: Jay Lan <jlan@sgi.com>
Date: Sat, 27 Sep 2008 01:00:05 +0000
Subject: Re: kdump broken on Altix 350
Message-Id: <48DD8595.6030504@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080829180302.6e67c26e@halley.suse.de>	<20080829180531.0524a1e4@halley.suse.de>	<57C9024A16AD2D4C97DC78E552063EA30A0067D6@orsmsx505.amr.corp.intel.com>	<20080910134805.488b43f9@kepler.site>
	<48C82C4F.1050002@sgi.com>
In-Reply-To: <48C82C4F.1050002@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: kexec@lists.infradead.org, Bernhard Walle <bwalle@suse.de>, Simon Horman <horms@verge.net.au>, linux-ia64@vger.kernel.org

Jay Lan wrote:
> Bernhard Walle wrote:
>> * "Luck, Tony" <tony.luck@intel.com> [2008-08-29]: 
>>
>>>> your commit
>>>>
>>>>     commit 10617bbe84628eb18ab5f723d3ba35005adde143
>>>>     Author: Tony Luck <tony.luck@intel.com>
>>>>     Date:   Tue Aug 12 10:34:20 2008 -0700
>>>>
>>>>     [IA64] Ensure cpu0 can access per-cpu variables in early boot
>>>> code
>>>>
>>>> broke kdump on our Altix 350. I get following early crash in kdump
>>>> kernel
>>> Sorry about that.  I'll try to reproduce it here.
>> I had some discussion about that with Jay Lan that he could not
>> reproduce that on his machine. We thought it was different config, but
>> now I can verify that the problem is reproducible here with the default
>> configuration (plus CONFIG_SATA_VITESSE).
> 
> Hi Bernhard and Tony,
> 
> I started seeing this problem, and it affected A4700 in addition to
> A350.
> 
> It was not clear the system hang was related to this problem. I saw a
> kdump kernel hang at cpu_init() at an A350, and a hang in find_memory
> on handling pernode space thing at an A4700. No error records and no
> backtrace, so i did not relate my problem to this one at first.
> 
> Out of curiosity, i backed out Tony's patch mentioned from 2.6.27-rc5
> and the kdump kernel hangs were gone on both systems.
> 
> Also, i had a kdump kernel MCA problem that was caused by kexec
> underallocating kernel memory for the kdump kernel. The  problem
> does not happen again after i backed out the patch.

Tony and Simon,

The program headers (PT_LOAD) of vmlinux before Tony's patch look
like these:

Program Headers:
Type     Offset             VirtAddr           PhysAddr
         FileSiz            MemSiz              Flags  Align
LOAD     0x0000000000010000 0xa000000100000000 0x0000000004000000
         0x0000000000d04480 0x0000000000d04480  RWE    10000
LOAD     0x0000000000d20000 0xffffffffffff0000 0x0000000004d10000
         0x0000000000009620 0x0000000000009620  RW     10000
LOAD     0x0000000000d30000 0xa000000100d20000 0x0000000004d20000
         0x00000000000bef50 0x0000000000564c90  RW     10000

The program headers of vmlinux after Tony's patch look like
these:
Program Headers:
Type     Offset             VirtAddr           PhysAddr
         FileSiz            MemSiz              Flags  Align
LOAD     0x0000000000010000 0xa000000100000000 0x0000000004000000
         0x0000000000d04480 0x0000000000d04480  RWE    10000
LOAD     0x0000000000d20000 0xffffffffffff0000 0x0000000004d20000
         0x0000000000009620 0x0000000000009620  RW     10000
LOAD     0x0000000000d30000 0xa000000100d30000 0x0000000004d30000
         0x00000000000bef58 0x0000000000564c90  RW     10000

The first PT_LOAD is for code, the second for percpu, and the
third for data. The FileSiz and MemSiz of the code and percpu
headers in both cases are identical. The only difference is the
PhyAddr of the percpu header after the patch is 0x10000 greater
than in the case of before patch.

Tony's patch put per-cpu area for cpu0 in the vmlinux itself
(in the percpu section of the ELF executable). If i read the
code correctly, he added extra PERCPU_PAGE_SIZE (0x10000 in ia64)
to the code segment. That explains why the PhysAddr of the percpu
segment became 0x10000 greater after the patch.

Howver, shouldn't the MemSiz of the code segment 0x10000 larger?
The current logic of add_loaded_segments_info() in
kexec/arch/ia64/crashdump-ia64.c counts on that information to
correctly determine how much memory is needed for vmlinux.

I could not figure out how the MemSiz of the code PL_LOAD
header in vmlinux is determined and set.

Regards,
 - jay
