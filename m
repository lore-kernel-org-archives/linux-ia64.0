From: Erich Focht <efocht@hpce.nec.com>
Date: Mon, 12 Jul 2004 11:24:11 +0000
Subject: Re: Consistency problem on IPF
Message-Id: <200407121324.11526.efocht@hpce.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40F2562C.10208@inria.fr>
In-Reply-To: <40F2562C.10208@inria.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 12 July 2004 13:12, Duraid Madina wrote:
> For the record, on HP-UX 11.23 the standard deviation is down around 
> 0.1s for NP0, 512. For N24, it's basically zero. This is on a 2-way 
> 1.5G/6M system.

Which page-size was the testcode using? HPUX is more flexible here due
to different usage of the TLB.

What compiler? The initial mail sounded like gcc has been used. I'd
expect a reasonable (i.e. optimizing) compiler to recognize the
trivial matrix-matrix multiply pattern and replace it by highly
optimized code. Which would reduce the problems...

> Linux has a way to go yet...

Might be, but one should check whether comparing apples with apples
;-)

Erich

