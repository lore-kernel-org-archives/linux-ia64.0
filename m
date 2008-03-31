From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Mon, 31 Mar 2008 07:57:40 +0000
Subject: RE: [kvm-ia64-devel] [09/17] [PATCH] kvm/ia64: Add mmio decoder for kvm/ia64.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC0104820A@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF7@pdsmsx415.ccr.corp.intel.com> <1206887670.47efa4f6290f8@imp.free.fr>
In-Reply-To: <1206887670.47efa4f6290f8@imp.free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tgingold@free.fr
Cc: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, Jes Sorensen <jes@sgi.com>, Akio Takebe <takebe_akio@jp.fujitsu.com>, kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, virtualization@lists.linux-foundation.org, Carsten Otte <cotte@de.ibm.com>

tgingold@free.fr wrote:
> Hi,
> 
> Selon "Zhang, Xiantao" <xiantao.zhang@intel.com>:
> 
>>> From 5f82ea88c095cf89cbae920944c05e578f35365f Mon Sep 17 00:00:00
>>> 2001 
>> From: Xiantao Zhang <xiantao.zhang@intel.com>
>> Date: Wed, 12 Mar 2008 14:48:09 +0800
>> Subject: [PATCH] kvm/ia64: Add mmio decoder for kvm/ia64. [...]
>> +			post_update = (inst.M5.i << 7) + inst.M5.imm7;
>> +			if (inst.M5.s)
>> +				temp -= post_update;
>> +			else
>> +				temp += post_update;
> 
> The sign extension is not done correctly here.  (This has been fixed
> in Xen code).

Include the fix in the latest merge candidate patchset.  Thanks! :)

git://git.kernel.org/pub/scm/linux/kernel/git/xiantao/kvm-ia64.git
kvm-ia64-mc8

> 
>> +			post_update = (inst.M3.i << 7) + inst.M3.imm7;
>> +			if (inst.M3.s)
>> +				temp -= post_update;
>> +			else
>> +				temp += post_update;
> 
> Ditto.
> 
>> +		post_update = (inst.M10.i << 7) + inst.M10.imm7; +
if
>> (inst.M10.s) +			temp -= post_update;
>> +		else
>> +			temp += post_update;
> 
> Ditto.
> 
>> +		post_update = (inst.M10.i << 7) + inst.M10.imm7; +
if
>> (inst.M10.s) +			temp -= post_update;
>> +		else
>> +			temp += post_update;
> 
> Ditto.
> 
>> +		post_update = (inst.M15.i << 7) + inst.M15.imm7; +
if
>> (inst.M15.s) +			temp -= post_update;
>> +		else
>> +			temp += post_update;
> 
> Ditto.
> 
> Tristan.

