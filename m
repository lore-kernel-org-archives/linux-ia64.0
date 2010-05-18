From: Robin Holt <holt@sgi.com>
Date: Tue, 18 May 2010 20:43:55 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <20100518204355.GB2944@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> holt@sgi.com (1):
>       [IA64] ia64 does not pass stack_start != 0 while copy_process expects it.

Wait!!!  I ended up finding a bigger bug in the general kernel.
I don't think this patch should go in.

Thanks,
Robin
