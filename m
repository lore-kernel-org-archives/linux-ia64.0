From: Carsten Otte <cotte@de.ibm.com>
Date: Tue, 01 Apr 2008 07:53:28 +0000
Subject: Re: [04/17] [PATCH] Add kvm arch-specific core code for kvm/ia64.-V8
Message-Id: <47F1E9F8.6010801@de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC01048245@pdsmsx415.ccr.corp.intel.com>
	<47F0FAA5.2090109@de.ibm.com>
	<42DFA526FC41B1429CE7279EF83C6BDC01048488@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDC01048488@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, kvm-ia64-devel@lists.sourceforge.net, carsteno@de.ibm.com, Jes Sorensen <jes@sgi.com>, Avi Kivity <avi@qumranet.com>, virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net

Zhang, Xiantao wrote:
> Hi, Carsten 
>      Why do you think it is racy?  In this function,
> target_vcpu->arch.launched should be set to 1 for the first run, and
> keep its value all the time.  Except the first IPI to wake up the vcpu,
> all IPIs received by target vcpu should go into "else" condition. So you
> mean the race condition exist in "else"  code ?
For example to lock against destroying that vcpu. Or, the waitqueue 
may become active after if (waitqueue_active()) and before 
wake_up_interruptible(). In that case, the target vcpu might sleep and 
not get waken up by the ipi.
