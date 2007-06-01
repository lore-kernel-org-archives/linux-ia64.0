From: Prarit Bhargava <prarit@redhat.com>
Date: Fri, 01 Jun 2007 10:30:17 +0000
Subject: Re: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <465FF539.6090506@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A01961AFE@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A01961AFE@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Christoph Lameter <clameter@sgi.com>, Randy Dunlap <randy.dunlap@oracle.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>, Vivek Goyal <vgoyal@in.ibm.com>



Luck, Tony wrote:
>> I used the sn2_defconfig in the tree :)
>>     
>
> So there is something odd happening.  Russ complained that he
> was still seeing several errors from the sn2_defconfig build
> too when I posted the "last fix" to Len.  But I don't see them
> when I build.
>
>   

Adding Vivek.

I've solved quite a few of the section mismatch errors as well.  I'll 
take a look to see what the problem is.

Tony, what system are you using to compile on, OS, etc?

P.

> -Tony
>   
