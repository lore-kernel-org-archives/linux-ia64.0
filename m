From: Richard Hirst <rhirst@linuxcare.com>
Date: Fri, 20 Jul 2001 17:33:34 +0000
Subject: Re: [Linux-ia64] 010626 kernel, copy_from_user() broken?
Message-Id: <marc-linux-ia64-105590693005856@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005846@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005846@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jul 19, 2001 at 12:25:35PM -0700, David Mosberger wrote:
> >>>>> On Thu, 12 Jul 2001 12:16:58 +0100, Richard Hirst <rhirst@linuxcare.com> said:
> 
>   Rich> Hi, Summary: I had to change PIPE_DEPTH in
>   Rich> arch/ia64/lib/copy_user.S from 21 to 4 to make
>   Rich> copy_from_user() work with non-aligned user addresses on my B3
>   Rich> cpu.  PIPE_DEPTH was 4 in the 010530 kernel.
> 
> Thanks for reporting this (and for tracking it down!).  It turns out
> that the author of the copy_user() recovery code either knowingly or
> accidentally assumed that PIPE_DEPTH=4, which is of course not good
> as it defeats the whole purpose of making the sw-pipelined loop
> tunable.  The patch below should fix this.  Can you try it instead and
> let me know how it goes?

Works fine, thanks.

Richard


