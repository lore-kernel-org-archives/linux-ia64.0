From: Amy Parker <enbyamy@gmail.com>
Date: Sat, 06 Feb 2021 17:09:19 +0000
Subject: Re: [PATCH] ia64: Fix style guide breakage
Message-Id: <CAE1WUT5pXOH=wjzcXBZ4YiFoVv6Xyb1sT5mxdm=NR1A1MqKgjw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210205220618.611388-1-enbyamy@gmail.com> <a3215a2b-76d3-6285-8072-160a905de362@physik.fu-berlin.de>
In-Reply-To: <a3215a2b-76d3-6285-8072-160a905de362@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Cc: schnelle@linux.ibm.com, corbet@lwn.net, mchehab+huawei@kernel.org, tsbogend@alpha.franken.de, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Sat, Feb 6, 2021 at 8:07 AM John Paul Adrian Glaubitz
<glaubitz@physik.fu-berlin.de> wrote:
>
> Hi Amy!
>
> On 2/5/21 11:06 PM, Amy Parker wrote:
> > Some statements do not have proper spacing between their C
> > keywords (commonly if and for) throughout files in the ia64 tree.
> > This patch corrects this to follow the kernel code style guide.
> >
> > Signed-off-by: Amy Parker <enbyamy@gmail.com>
>
> I never noticed. Does the kernel coding style guideline actually require
> space after "for" and "if" and similar statements but not before function
> names?

Yes it does, actually!

> So use a space after these keywords:
> if, switch, case, for, do, while

> int system_is_up(void)
> {
>         return system_state = SYSTEM_RUNNING;
> }


   -Amy IP
