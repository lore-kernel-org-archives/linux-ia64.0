From: Keith Owens <kaos@sgi.com>
Date: Sat, 04 Feb 2006 00:36:00 +0000
Subject: Re: ia64 printk_clock()
Message-Id: <16487.1139013360@ocs3>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens (on Sat, 04 Feb 2006 11:16:09 +1100) wrote:
>"Luck, Tony" (on Fri, 3 Feb 2006 10:43:08 -0800) wrote:
>>> Now that I read the whole thread, how about remove pining DTR 
>>> requirement for per-cpu data?  In alt_dtlb_miss, we can just
>>> detect whether ifa is per_cpu address and read ar.k3 to get the
>>> physical address, then insert a TC.  That will free up a tlb
>>> entry for application to use.
>>
>>What will you do when someone accesses per-cpu area before ar.k3
>>has been initialized (the bug that we are trying to fix here)?
>>
>>This would add some extra code to the Alt-DTLB handler.  Could
>>you hide all/most of the extra latency?
>>
>>Are there any correctness issues?  Any place where we access a
>>per-cpu variable where we absolutely cannot take an Alt-DTLB fault?
>
>mca_asm.S, GET_IA64_MCA_DATA().  ia64_mca_data is per cpu and is
>accessed right from the start of the MCA/INIT handlers, with psr.i,
>psr.ic both 0.

Ignore that, ia64_mca_data and the data that it points to uses physical
addresses, not virtual.

