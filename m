From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 03 Nov 2004 16:57:56 +0000
Subject: RE: [PATCH] top level scheduler domain for ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F025111CF@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> > Is '6' a reasonable default if the parameter is not set?
>>
>> Maybe for Altix.  I guess the only user of this domain split
>> is Altix, so it's ok ;)
>
>Yep, looks good to me.  Thanks.

So tell me who wants a value other than 6, and what is the value
that they want?  I was hoping for some more specific advice in 
the kernel-parameters.txt file.  What's a good choice for a 16-node
machine?  For a 128-node machine?

-Tony
