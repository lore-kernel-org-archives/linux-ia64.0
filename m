From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 24 Nov 2004 17:51:24 +0000
Subject: RE: [PATCH 1/2] setup_arg_pages can insert overlapping vma
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0271E665@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <894E37DECA393E4D9374E0ACBBE7427013C9AB@pdsmsx402.ccr.corp.intel.com>
In-Reply-To: <894E37DECA393E4D9374E0ACBBE7427013C9AB@pdsmsx402.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>, "Zou, Nanhai" <nanhai.zou@intel.com>
Cc: hugh@veritas.com, chrisw@osdl.org, torvalds@osdl.org, schwidefsky@de.ibm.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>"Zou, Nanhai" <nanhai.zou@intel.com> wrote:
>>
>> I think ia64 ia32
>> subsystem is not vulnerable to this kind of overlapping vm problem,
>> because it does not support a.out binary format, 
>> X84_64 is vulnerable to this. 
>
>Martin, Andi and Tony: could we please get a 2.6.10 ack on 
>this from you?

I can "Ack" it too ... but I gave Nanhai one of my "Signed-off-by:"
lines which he already attached to this patch :-)

-Tony
