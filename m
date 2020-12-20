From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Sun, 20 Dec 2020 18:41:53 +0000
Subject: Re: where to start with ia64 kernel
Message-Id: <202178aa-7f8d-5c77-115d-3390614e7500@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <CADxRZqwfMr9==xFQaaEOk7jYVoROEEyQ_12KpBCtwL3SXoCM-A@mail.gmail.com>
In-Reply-To: <CADxRZqwfMr9==xFQaaEOk7jYVoROEEyQ_12KpBCtwL3SXoCM-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Anatoly!

On 12/20/20 7:13 PM, Anatoly Pugachev wrote:
> I have Integrity BL870c i4 blade installed with debian sid, somewhat
> working 4.15/4.14.x kernel series...
> 
> 4.16.x kernel (and more recent ones, including latest git) does not boot ...
> tried to bisect (but some kernel revisions does not even compile - git
> bisect skip).

Any kernel newer than 4.14.x will not boot on large ia64 NUMA systems due
to the changes in 543cea9a [1][2]. This bug does not affect systems like
the RX-2600 which boot Linux 5.9 just fine.

There are two minor regressions in 5.10, one has already been bisected [3]

> Does it make sense to try to start reporting bugs and hangs with ia64
> 4.x kernel series, being 5.10 is out...

Not really as 5.9.0 boots on smaller systems like the RX-2600 and the issue
with the larger systems has already been bisected to 543cea9a.

The problem with the regression you are seeing is that multiple attempts to
fix the issue have so far failed and we haven't found a working fix yet.

Adrian

> [1] https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?idT3cea9accd9804307541cb93d3ed7ec94b07237
> [2] https://marc.info/?l=linux-ia64&m6144480821712&w=2
> [3] https://marc.info/?l=linux-arm-kernel&m0832710326221&w=2

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
