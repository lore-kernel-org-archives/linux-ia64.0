From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Sat, 29 Mar 2008 02:16:29 +0000
Subject: RE: [kvm-devel] [14/17][PATCH] kvm/ia64: Add guest interruptioninjection support.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCFF7F60@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF2@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EF2@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


 INITIAL_PSR_VALUE_AT_INTERRUPTION 0x0000001808028034
>> +
> Xen also use this value, you had better use macros of PSR bits.
> Or you can add the same comments as Xen.
Hi, Akio.
The comment is where it is used. Anyway, using macro is better.
Changed. 
