From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 07 Oct 2004 08:04:14 +0000
Subject: Re: sparse cleanups for ia32 subsystem
Message-Id: <16740.63614.271870.57061@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16738.33692.510681.306179@napali.hpl.hp.com>
In-Reply-To: <16738.33692.510681.306179@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 06 Oct 2004 15:39:58 -0700, Arun Sharma <arun.sharma@intel.com> said:

  Arun> On 10/5/2004 4:21 AM, David Mosberger wrote: Hi David,

  >> Hi Arun,

  >> Below is a complete patch for the sparse-triggered changes to the
  >> ia32 subsystem.  I take it you may have done some of this already
  >> but I hope the patch is still useful.  Please feed the patches to
  >> Tony as you see fit.

  Arun> Thanks for doing this! I've taken care of the remaining sparse
  Arun> warnings and fixed up a couple of issues you found. Details
  Arun> inside the patch.

Looks great to me!

  Arun> Tony, please apply.

Once this patch hits Tony's patch, there is no excuse anymore to not
run sparse.  I'd highly recommend it to everyone hacking on the kernel
as it can find some nasty bugs.

	--david

