From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 25 Sep 2003 09:04:07 +0000
Subject: Re: [Lse-tech] CPUSET Proposal
Message-Id: <marc-linux-ia64-106448082716218@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106442121824485@msgid-missing>
In-Reply-To: <marc-linux-ia64-106442121824485@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2003-09-24 at 23:57, David Mosberger wrote:
> I wasn't suggesting that x86 is limited to 8-way, I was wondering how
> many > 8-way x86 Linux machines are actually out there.  I wasn't even
> being facetious---just curious.

Well, besides the NUMA-Q, which went up to 60x and is dead now, there
are at least the IBM Summit chipset machines.  They're sold as 32-ways
today on the x445 (that's physical, without hyperthreading).  I've
personally booted Linux on a 16-way, but I'm know others have booted on
the 32-way configuration.  Patches for this were posted in the last week
by James Cleverdon.  

There's also the bigsmp code in the kernel for other P4-based systems
that are >8x.  I haven't seen any of them yet, but I wouldn't imagine
that people would put support in the kernel for hardware that wasn't at
least *close* to production. 

-- 
Dave Hansen
haveblue@us.ibm.com

