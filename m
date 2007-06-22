From: Bernhard Walle <bwalle@suse.de>
Date: Fri, 22 Jun 2007 09:41:53 +0000
Subject: Re: [IA64] [kdump] machveg=dig on hpzx1 platforms
Message-Id: <20070622094153.GA18449@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070621182441.GA21840@suse.de> <467AE260.7030906@hp.com>
In-Reply-To: <467AE260.7030906@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Terry Loftin <terry.loftin@hp.com>
Cc: linux-ia64@vger.kernel.org, Khalid Aziz <khalid_aziz@hp.com>, kexec@lists.infradead.org

Hi Terry,

* Terry Loftin <terry.loftin@hp.com> [2007-06-21 22:41]:
>
>> Are there any plans to bring back ioc_iova_disable(), or would some
>> automatic kernel code that uses machvec=dig in the kernel without
>> forcing the user to pass an additional command line work?
>
> Here is a patch to do that.  We use this internally, but
> I had forgotten to post it.

Thanks for your explanation and the patch.

Can you try to bring it mainline? Since it affects only
arch/ia64/hp/*, I don't see a reason why it should be rejected.


Thanks,
   Bernhard
