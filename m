From: Christian Hildner <christian.hildner@hob.de>
Date: Mon, 24 Jan 2005 07:51:17 +0000
Subject: Re: optimize __gp location
Message-Id: <41F4A8F5.3020207@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B05667366EE6204181EABE9C1B1C0EB50589FCE9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W schrieb:

>__gp is positioned so far out that it is almost at the end of all data
>sections.  On 2.6.11-rc1, 80% of kernel data symbols are out of 22-bit
>immediate offset from __gp.  This means accessing these symbols are 
>unnecessarily expansive such that they have to go through global offset
>table (a memory load to get the symbol address).  Among these out of
>reach symbols from __gp, some are very frequently used, like Jiffies,
>etc.
>
Wouldn't a solution using movl for the offset and then add to gp be the 
cheaper solution in terms of cycles? I am wondering that there is an 
additional and expensive load needed with the item possibly (likely or 
not) being not in the cache. But there are the software conventions and 
"nobody will ever need more than" 4MB of short data.

>Can we position the __gp somewhat more optimally, to cover more of these
>symbols? Something like the following patch would make all of them fall
>into the 22-bit immediate offset relative to gp.
>
Did you have benchmarks? Or at least a comparison of the resulting code 
size. The code size should shrink when more items can be addressed 
directly. Furthermore the code size should be a good indicator for the 
performance gain you could achive.

Christian

