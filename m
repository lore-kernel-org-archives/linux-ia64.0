From: "Luming Yu" <luming.yu@gmail.com>
Date: Tue, 16 Oct 2007 01:14:49 +0000
Subject: Re: [RFC patch] use thread.on_ustack to determine if on user stack
Message-Id: <3877989d0710151814s5eddf7f5y801106b725c1d4cc@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3877989d0709290053s7b4e80b6t9e7127b9ccac522b@mail.gmail.com>
In-Reply-To: <3877989d0709290053s7b4e80b6t9e7127b9ccac522b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I was thinking the fsys_bubble_down is used to fall back to normal
system call entry if that don't have a ligtweight handler.
Is it right.

On 10/16/07, Fenghua Yu <fenghua.yu@intel.com> wrote:
> On Mon, Oct 15, 2007 at 12:28:05PM +0800, Luming Yu wrote:
> > So my problem is I don't know if it is  true that pUStk =
> > thread.on_ustack in fsys mode. And I didn't locate the code that the
> > thread.on_ustack is cleared to 0 during fsys mode.
> > So please help.
>
> In fsys call, pUStk is never equal to thread.on_ustack. Here is the code in
> fsys_bubble_down() in fsys.S.
>
> ....
>         st1 [r16]=r0                            // M2|3 clear current->thread.on_ustack flag
> ....
>         cmp.ne pKStk,pUStk=r0,r0                // A    set pKStk <- 0, pUStk <- 1
> ....
>
> The code shows that thread.on_ustack=0 and pUStk=1 during fsys setup phase. The
> two should be equal in other cases than fsys. Seems the two similar names cause
> confusion.
>
> Thanks.
>
> -Fenghua
>
