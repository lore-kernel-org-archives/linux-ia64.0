From: Christian Hildner <christian.hildner@hob.de>
Date: Wed, 03 May 2006 08:07:35 +0000
Subject: Re: [RFC 2/3] LVHPT - Setup LVHPT
Message-Id: <445864C7.9050800@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F066076B6@scsmsx401.amr.corp.intel.com> <4t153d$t4bok@azsmga001.ch.intel.com> <20060503074903.GB4798@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ian Wienand <ianw@gelato.unsw.edu.au>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org

Ian Wienand schrieb:

>Being relatively inexperienced, all this dynamic patching (SMP, page
>table, this) scares me in that what is executing diverges from what
>appears to be in source code, making difficult things even more
>difficult to debug.  Is there consensus that a long term goal should
>be that short and long formats should be dynamically selectable?
>
Yes. So why not picking up Ken's idea of two parallel IVTs. Best 
practice and probably the most readable solution might be the usage of 
common macros for all the common entires (like EXTERNAL_INTERRUPT_CODE), 
so that only the VHPT-specific entries would be coded directly in the 
corrensponding ivt.S. Straightforward and without patching, code 
generation, ...

Christian

