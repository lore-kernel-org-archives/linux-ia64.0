From: Carsten Otte <cotte@de.ibm.com>
Date: Tue, 01 Apr 2008 07:48:09 +0000
Subject: Re: [01/17]PATCH  Add API for allocating dynamic TR resouce. V8
Message-Id: <47F1E8B9.3010806@de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC0104823F@pdsmsx415.ccr.corp.intel.com>
	<47F0EA15.9030408@de.ibm.com>
	<42DFA526FC41B1429CE7279EF83C6BDC010483DA@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDC010483DA@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, kvm-ia64-devel@lists.sourceforge.net, carsteno@de.ibm.com, Jes Sorensen <jes@sgi.com>, Avi Kivity <avi@qumranet.com>, virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net

Zhang, Xiantao wrote:
> Carsten Otte wrote:
>> Zhang, Xiantao wrote:
>>> +/*  mca_insert_tr
>>> + *
>>> + *  Switch rid when TR reload and needed!
>>> + *  iord: 1: itr, 2: itr;
>>> + *
>>> +*/
>>> +static void mca_insert_tr(u64 iord)
>>> +{
>>> +
>>> +	int i;
>>> +	u64 old_rr;
>>> +	struct ia64_tr_entry *p;
>>> +	unsigned long psr;
>>> +	int cpu = smp_processor_id();
>> What if CONFIG_PREEMPT is on, and we're being preempted and scheduled
>> to a different CPU here? Are we running preempt disabled here? If so,
>> the function header should state that this function needs to be called
>> preempt_disabled.
> 
> The function insert one TR to local TLB, and doesn't allow preempt
> before and after the call, so the caller should be with preempt_disable
> before calling into this routine. 
> Maybe the descripiton of this function should contain "Called with
> preempt disabled!".  Does it make sense ?
Yea, I think a comment would help in that case :-).

