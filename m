From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 26 Aug 2003 18:16:49 +0000
Subject: Re: HP_SIM with performance monitoring
Message-Id: <marc-linux-ia64-106192195729229@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106186435806640@msgid-missing>
In-Reply-To: <marc-linux-ia64-106186435806640@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ian,

On Tue, Aug 26, 2003 at 12:18:46PM +1000, Ian Wienand wrote:
> 
> I noticed that when trying to boot 2.6.0-test4 in the simulator with
> perfmon turned on it ended up oopsing with a "General Exception: IA-64
> Reserved Register/Field fault" in pfm_init_percpu() when it tried to
> zero out the PMD registers.
> 

That does not surprise me. The simulator does have some PMD and PMC registers
but they do not count anything.

> I have no idea if the simulator implements perfmon support, but
> noticed that there are PMC and PMD registers in the register window.
> Am I right in saying the simulator has only 8, skipping odd registers,
> where mckinley has 15 PMC and 17 PMD registers?

Ski seems to have 16 PMCS and 16 PMDS implemented.

> 
> I can think of a number of things to fix it but am not sure which is
> correct -- the GENERIC definitions look kind of correct; maybe
> CONFIG_PERFMON should be turned off for HP_SIM; or create a dummy
> PMC/PMD register definition (attached).  Any enlightenment
> appreciated.

Yes, something along the lines of your patch would be a clean way of fixing
the problem. However, I would do something similar to what is in 
perfmon_generic.h. Simply define the PMDS as counters (PFM_REG_COUNTING). 
It will not hurt because they actually do not count anything. And create 
the PMC table as counter (PFM_REG_COUNTING).

Thanks for spotting this problem.

--
-Stephane
