From: Ashok Raj <ashok.raj@intel.com>
Date: Wed, 09 Feb 2005 23:12:21 +0000
Subject: Re: [PATCH] CPU hotplug returns CPUs to SAL
Message-Id: <20050209151221.A501@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1107970828.5478.22.camel@tdi>
In-Reply-To: <1107970828.5478.22.camel@tdi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 09, 2005 at 04:04:14PM -0700, Alex Williamson wrote:
> On Wed, 2005-02-09 at 14:38 -0800, Ashok Raj wrote:
> 
> > Could you give it a try on your systems and give an udpate.
> > 
> > In the meantime, i will try to incorporate the missing pieces as another update
> > to this patch.
> 
> Ashok,
> 
>   I'm running it in a loop (not under load) on both a zx1 and an sx1000
> based system now.  Looks good on both.  We should definitely try to be
> architecturally complete on the registers that get preserved, but we
> don't seem to have any obvious dependency on the missing ones.  Thanks,
> 


i will work on the missing registers save/restore, but iam glad its not
breaking anything.

Thanks a ton!
-- 
Cheers,
Ashok Raj
- Linux OS & Technology Team
