From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 11 May 2004 15:42:01 +0000
Subject: RE: [2.6.6 PATCH] Exposing EFI memory map
Message-Id: <1084290121.1091.62.camel@nighthawk>
List-Id: <linux-ia64.vger.kernel.org>
References: <00b201c43766$7646a670$39624c0f@india.hp.com>
In-Reply-To: <00b201c43766$7646a670$39624c0f@india.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sourav Sen <souravs@india.hp.com>
Cc: 'Greg KH' <greg@kroah.com>, Matt_Domsch@dell.com, Matthew E Tolentino <matthew.e.tolentino@intel.com>, linux-ia64@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, 2004-05-11 at 07:44, Sourav Sen wrote:
> + I think you should address the other issues in this thread before
> + worrying about the sysfs interface (why have this at all, incorrect
> + data for hotplug mem, etc.)
> + 
> 	I did not hear whether the idea of updating efi memory map on a 
> hotplug is good or bad. In any case, can somebody tell me to how do 
> I get the available physical range map (only the ranges that VM is 
> using at a given point in time) from userland. I believe I outlined 
> a legitimate requirement earlier in this thread :-)

Let me paraphrase: exporting generic information in an architecture or
firmware-specific way in sysfs is bad.

I apologize, but I think I missed yout legitimate requirements earlier
in the thread.  Could you briefly remind me?

-- Dave

