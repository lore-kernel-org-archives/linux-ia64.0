From: Prarit Bhargava <prarit@redhat.com>
Date: Fri, 01 Jun 2007 03:31:33 +0000
Subject: Re: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <465F9315.2050207@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A01961A60@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A01961A60@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Christoph Lameter <clameter@sgi.com>, Randy Dunlap <randy.dunlap@oracle.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>



Luck, Tony wrote:
>> Tony, the ia64 section mismatch "whack-a-mole" is far from over :(
>>     
>
> Can you post the .config file that you are using when you see all those
> warnings ... I'll start bopping them on their cute little heads.
>
>   

Hi Tony,

I used the sn2_defconfig in the tree :)

P.

> -Tony
>   
