From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 05 Oct 2004 07:21:26 +0000
Subject: Re: yet another sparse-detected bug fix
Message-Id: <16738.19318.847723.674038@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410041545.i94FjQd0031552@napali.hpl.hp.com>
In-Reply-To: <200410041545.i94FjQd0031552@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 04 Oct 2004 12:46:41 -0700, Arun Sharma <arun.sharma@intel.com> said:

  Arun> On 10/4/2004 8:45 AM, David Mosberger wrote:
  Arun> Hi David,

  >> Arun,
  >> 
  >> copy_siginfo_from_user32() directly dereferences a user-pointer, which
  >> is a no-no.  At that point, to->si_code already has been initialized
  >> so I think we can just use to->si_code instead.  Compile-tested (only)
  >> patch attached.
  >> 
  >> Signed-off-by: davidm@hpl.hp.com

  Arun> I've been meaning to run sparse myself. But it wasn't very effective the last time I tried because of the missing __user annotations.

  Arun> Please review the attached patches that add the missing
  Arun> annotations so that we can make it easy to spot these errors
  Arun> in the future.

I'm confused.  I posted a sparse-enablement patch yesterday.  Was
there something wrong with that one?

	--david
