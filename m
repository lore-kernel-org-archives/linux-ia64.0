From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jan 2002 19:25:31 +0000
Subject: RE: [Linux-ia64] [PATCH]  Support for alternative kernel profiler
Message-Id: <marc-linux-ia64-105590698805794@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805742@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805742@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 9 Jan 2002 13:37:34 -0800 , "Luck, Tony" <tony.luck@intel.com> said:

  Tony> It turns out that we don't really need to have init_tasks[]
  Tony> exported.  Here is a revised version of the patch with just
  Tony> the change to add SA_PERCPU_IRQ to the flags accepted by
  Tony> request_irq()

I'd like Stephane to take a look at this patch and see whether there
are any potential bad interactions with the PMU code he is working on
(due to the manipulation of the psr.pp bit).  Other than that, the
patch looks good to me.

	--david

