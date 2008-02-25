From: "stephane eranian" <eranian@googlemail.com>
Date: Mon, 25 Feb 2008 23:00:46 +0000
Subject: Re: 2.6.24 new perfmon kernel code base + libpfm + pfmon finally available!
Message-Id: <7c86c4470802251500mafec0dl535591971258de69@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <7c86c4470802250900g1eea7a26m1900c4d8ed621dfd@mail.gmail.com>
	 <84144f020802251113m2cede5bbx9044ec1fc6d11f0c@mail.gmail.com>
In-Reply-To: <84144f020802251113m2cede5bbx9044ec1fc6d11f0c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, ia64 <linux-ia64@vger.kernel.org>

Pekka,

On Mon, Feb 25, 2008 at 8:13 PM, Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> Hi Stephane,
>
>
>  On Mon, Feb 25, 2008 at 7:00 PM, stephane eranian
>  <eranian@googlemail.com> wrote:
>  >  I have finally released the perfmon2 kernel patch for kernel v2.6.24. It
>  >  took longer than expected to due my job change and several technical issues
>  >  related to perfmon kernel bugs.
>
>  [snip]
>
>
>  >  As usual all files and more detailed change logs can be downloaded
>  >  from our website at:
>  >
>  >        http://perfmon.sourceforge.net
>
>  Why not post the patches on LKML for review?
>
I have done that in the past. I will do this again. But if you look at
the patch as it is released, you will
see that it is very large. Not that easy to split for LKML review.
With now with GIT that may be easier.
I intend to start posting small bits and pieces from now on.
