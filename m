From: "Ren, Qiaowei" <qiaowei.ren@intel.com>
Date: Mon, 27 Oct 2014 01:43:00 +0000
Subject: RE: [PATCH v9 09/12] x86, mpx: decode MPX instruction to get bound violation information
Message-Id: <9E0BE1322F2F2246BD820DA9FC397ADE0180ED16@shsmsx102.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com>
 <1413088915-13428-10-git-send-email-qiaowei.ren@intel.com>
 <alpine.DEB.2.11.1410241408360.5308@nanos>
In-Reply-To: <alpine.DEB.2.11.1410241408360.5308@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>



On 2014-10-24, Thomas Gleixner wrote:
> On Sun, 12 Oct 2014, Qiaowei Ren wrote:
> 
>> This patch sets bound violation fields of siginfo struct in #BR
>> exception handler by decoding the user instruction and constructing
>> the faulting pointer.
>> 
>> This patch does't use the generic decoder, and implements a limited
>> special-purpose decoder to decode MPX instructions, simply because
>> the generic decoder is very heavyweight not just in terms of
>> performance but in terms of interface -- because it has to.
> 
> My question still stands why using the existing decoder is an issue.
> Performance is a complete non issue in case of a bounds violation and
> the interface argument is just silly, really.
> 

As hpa said, we only need to decode several mpx instructions including BNDCL/BNDCU, and general decoder looks like a little heavy. Peter, what do you think about it?

Thanks,
Qiaowei

