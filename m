From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Tue, 11 Nov 2003 07:17:11 +0000
Subject: Re: [PATCH] enable platform dependent MCA handling
Message-Id: <marc-linux-ia64-106853534811308@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106850974125144@msgid-missing>
In-Reply-To: <marc-linux-ia64-106850974125144@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I think it is more flexible that the plan that generic kernel have all the
platform specific code and have choices at run time, Keith said.
BTW, as doubt still I have, how I use this #ifdef in mca.c? Is it obsolete?

For the present, I'll try to use machvecs for this switching.
I have read through machvec.h briefly, and I could find following three
definitions:
  platform_mca_init (maybe, for INIT)
  platform_mca_handler (for MCA)
  platform_cmci_handler (for CMCI)

...Are there any plans to implement "platform_cpei_handler (for CPEI)"?
David?


Thanks.

------

H.Seto <seto.hidetoshi@jp.fujitsu.com>


