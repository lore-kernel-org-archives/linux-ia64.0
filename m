From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 27 Sep 2000 23:55:12 +0000
Subject: Re: [Linux-ia64] [PATCH] ivt.S
Message-Id: <marc-linux-ia64-105590678205527@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205523@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205523@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 27 Sep 2000 19:54:58 -0400, "Pat O'Rourke" <orourke@mclinux.com> said:

  >> #ifdef CONFIG_DISABLE_VHPT itlb_fault: #endif

  Pat> and a similar #ifdef in the dtlb case.

  Pat> [This code isn't in the last patch based on test8 that I am
  Pat> aware of (0913?)]

Yes, sorry about that.  This is new code added by Asit.  A new kernel
patch with this code will be out hopefully later this week.

Thanks,

	--david

