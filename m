From: Tony Luck <tony.luck@gmail.com>
Date: Thu, 11 Jun 2015 22:39:05 +0000
Subject: Re: [PATCH] ia64: remove paravirt code
Message-Id: <CA+8MBb+LSDWDVpo7C_Xp7j4WgrnYUXHDyLzxTDY=0_OgVEDrjg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1433270522-1973-1-git-send-email-mcgrof@do-not-panic.com>
	<CA+8MBb+R-et1VNrqsV6USUphwMfhiMBbLBVrrkQcma4b=wsLbA@mail.gmail.com>
	<CAB=NE6UZUGkx0hqoH3Y25cM-FQz25-_AxaA5OpKOAVfnNRFhHQ@mail.gmail.com>
In-Reply-To: <CAB=NE6UZUGkx0hqoH3Y25cM-FQz25-_AxaA5OpKOAVfnNRFhHQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Cc: "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, pbonzini@redhat.com, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Chris Wright <chrisw@sous-sol.org>, Jeremy Fitzhardinge <jeremy@goop.org>, Alok Kataria <akataria@vmware.com>, Rusty Russell <rusty@rustcorp.com.au>

On Wed, Jun 10, 2015 at 4:40 PM, Luis R. Rodriguez
<mcgrof@do-not-panic.com> wrote:
> Its quite a huge chunk of code removed, I doubt that .o files would
> remain intact after this, but I could be wrong. I think run time
> validation and examination of the code changes, understanding of the
> code changes is necessary, but also likely just as run time tests.

Actually it seems the most of the .o files below arch/ia64/kernel look quite
similar ... some post-processing of the "objdump -d" output the squash
out addreses ... and the before/after .o files have few enough differences
that they can be looked at manually.

> Is there no ia64 regression test suite?
Not really.

> I don't see ia64 getting much love anyway these days so would it not
> hurt to merge and spin through linux-next for a while and if no issues
> are reported make it fly in?

Not sure how many people besides me are booting linux-next kernels.

Still - let's give it a try,

-Tony
