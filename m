From: Kautuk Consul <consul.kautuk@gmail.com>
Date: Thu, 14 Jun 2012 16:53:18 +0000
Subject: Re: [PATCH 09/19 v2] ia64/mm/fault.c: Port OOM changes to ia64_do_page_fault
Message-Id: <CAFPAmTSoeo8Zxbz=D0VUzrG=NeNqX2AdaNvZ+xoKNQ9-8t=9Jw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1333195412-5217-1-git-send-email-consul.kautuk@gmail.com>
In-Reply-To: <1333195412-5217-1-git-send-email-consul.kautuk@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, Jun 14, 2012 at 10:13 PM, Luck, Tony <tony.luck@intel.com> wrote:
>> Maybe you can try my test-case at https://lkml.org/lkml/2012/3/31/90 ?
>
> There seem to be a few cut & paste errors in that version (threads 3, 4, 5
> think they are "Thread 2"). =A0Also no check for malloc failing (which si=
nce
> it is done in an infinite loop seems inevitable - unless your machines ha=
ve
> infinite memory :-)

Yes. This test-case was written in a hurry to run on ARM and the test-case =
was
just meant to blindly allocate and fault pages till OOM happens.

So sorry about that !

Evidently on ARM we OOM much before the mallocs start failing. That
maybe due to
some overcommit_memory setting which I had on that board.

>
> Fixed up version attached. =A0Seems to run without any lockups on a kernel
> with your patch applied until either the malloc's start to fail, or the O=
OM
> killer zaps it.

Thank you for that.
Really appreciate your help !

>
> I put your patch into my "next" tree - it's in linux-next tag "next-20120=
614"
> and I'll push to Linus in the next merge window.

And thanks again for that. :-)

>
> Thanks
>
> -Tony
>
>
