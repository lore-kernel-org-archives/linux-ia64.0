From: Jesse Barnes <jbarnes@sgi.com>
Date: Tue, 06 Nov 2001 01:03:29 +0000
Subject: Re: [Linux-ia64] itc sync & clock_*
Message-Id: <marc-linux-ia64-105590698805442@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805400@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805400@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yeah, sounds good.  I'm not sure about the name too, hopefully the
firmware folks will come up with something better.  ITC_MAY_DRIFT seems a
little clunky...

Jesse

On Mon, 5 Nov 2001, David Mosberger wrote:

> >>>>> On Wed, 31 Oct 2001 11:41:58 -0800, Jesse Barnes <jbarnes@sgi.com> said:
> 
>   Jesse> Here's a patch against 2.4.13+ia64 to export the sal platform
>   Jesse> features to a directory in /proc.  Please let me know if it's
>   Jesse> ok; I'll start working on the clock driver if it is.
> 
> Looks great to me!  I'll hold off with applying the patch until the
> firmware interface has been finalized, if that's all right with you.
> 
> Thanks,
> 
> 	--david
> 


