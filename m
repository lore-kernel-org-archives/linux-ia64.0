From: Andi Kleen <ak@suse.de>
Date: Wed, 28 Jan 2004 18:52:46 +0000
Subject: Re: [RFC/PATCH, 1/4] readX_check() performance evaluation
Message-Id: <20040128195246.47a84498.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <00a201c3e541$c0e7d680$2987110a@lsd.css.fujitsu.com>
	<20040128172004.GB5494@cup.hp.com>
	<20040128184137.616b6425.ak@suse.de>
	<16408.30.896895.980121@napali.hpl.hp.com>
In-Reply-To: <16408.30.896895.980121@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: davidm@napali.hpl.hp.com, iod00d@hp.com, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Wed, 28 Jan 2004 10:31:58 -0800
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> >>>>> On Wed, 28 Jan 2004 18:41:37 +0100, Andi Kleen <ak@suse.de> said:
> 
>   Andi> Also in my experience from AMD64 which originally was a bit
>   Andi> aggressive on enabling MCEs: enabling MCEs increases your
>   Andi> kernel support load a lot.
> 
>   Andi> Many people have slightly buggy systems which still happen to
>   Andi> work mostly.  If you report every problem you as kernel
>   Andi> maintainer will be flooded with reports about things you can
>   Andi> nothing to do about.
> 
> I find this comment interesting.  Can you elaborate what you mean by
> "slightly buggy systems"?

e.g. one bit ECC errors in memory are quite common.  And with ECC memory 
they are not really fatal. Similar with drivers. A lot of drivers do 
bus aborts and other things regularly, but there is not necessarily 
data corruption.

-Andi
