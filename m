From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Wed, 21 May 2008 09:46:53 +0000
Subject: RE: [patch] fix zero extending for mmio ld1/2/4 emulation in KVM
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDC012FC358@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4832A0A6.8050800@sgi.com>
In-Reply-To: <4832A0A6.8050800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen wrote:
> Matthew Chapman wrote:
>> Jes,
>> 
>> Glad you tracked it down.  Can I suggest rather than using memcpy, a
>> more efficient way might be something like...
>> 
>> #define ZERO_EXTEND(x,bits) ((x) & (~0UL >> (64-(bits))))
>> 
>> *dest = ZERO_EXTEND(p->u.ioreq.data, 8*s);
> 
> Much nicer indeed!
> 
> Here's a pretty version - Tony will you apply this one instead.
Hi, Jes
    Good catch!!   Since this is a key fix for 2.6.26, Avi or Tony may
help to push the fix into upstream.  :-)
Xiantao

