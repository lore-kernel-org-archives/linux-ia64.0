From: Andi Kleen <ak@suse.de>
Date: Wed, 28 Jan 2004 19:39:15 +0000
Subject: Re: [RFC/PATCH, 1/4] readX_check() performance evaluation
Message-Id: <20040128203915.22d84e8d.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a201c3e541$c0e7d680$2987110a@lsd.css.fujitsu.com>
	<20040128172004.GB5494@cup.hp.com>
	<20040128184137.616b6425.ak@suse.de>
	<16408.30.896895.980121@napali.hpl.hp.com>
	<20040128195246.47a84498.ak@suse.de>
	<16408.3157.336306.812481@napali.hpl.hp.com>
In-Reply-To: <16408.3157.336306.812481@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: davidm@napali.hpl.hp.com, iod00d@hp.com, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 28 Jan 2004 11:24:05 -0800
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> >>>>> On Wed, 28 Jan 2004 19:52:46 +0100, Andi Kleen <ak@suse.de> said:
> 
>   >> I find this comment interesting.  Can you elaborate what you mean by
>   >> "slightly buggy systems"?
> 
>   Andi> e.g. one bit ECC errors in memory are quite common.  And with
>   Andi> ECC memory they are not really fatal.
> 
> Yet they are a good indicator that something is wrong (not performing
> properly) or may be failing soon.  I don't think putting on blinders
> for such problems is a good idea.  Though I agree that the question of

Most server class hardware should log it somewhere and allow 
to read the event log in the firmware. This even works for unhandleable
errors unlike what the OS could do.

But when printed in Linux they will report it to the linux maintainer or their 
distribution vendor.  "My Linux is buggy and giving these weird messages" And they
are both in no position at all to do something about it. 

I toyed with the idea of printking a disclaimer of
"This is likely not a software bug. Report it to your hardware vendor."
But I doubt this would help much. Even when you say clearly in the message
that the hardware failed the user sees a weird message and thinks 
it is Linux's fault.

You could enable it with CONFIG_I_HAVE_A_HARDWARE_SUPPORT_CONTRACT_OR_I_WRITE_DRIVERS
Or just make it a kernel command line option with off by default.

-Andi
