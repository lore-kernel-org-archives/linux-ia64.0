From: Christian Hildner <christian.hildner@hob.de>
Date: Fri, 22 Feb 2002 11:35:51 +0000
Subject: Re: [Linux-ia64] VHPT performance
Message-Id: <marc-linux-ia64-105590701905166@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905139@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905139@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


David Mosberger schrieb:

> >>>>> On Wed, 20 Feb 2002 13:21:22 +0100, Christian Hildner <christian.hildner@hob.de> said:
>
>   Christian> Hi!  Does anybody have a benchmarking tool or test
>   Christian> program for performance comparisons on the VHPT feature?
>   Christian> Or are there applications that heavily use many different
>   Christian> memory pages?
>
> There certainly are!  The SPEC CPU benchmarks are quite memory intensive, for
> example.
>

I made some measures and found that on Itanium it takes about ~700 CPU cycles to load a single
byte when TLB is missing and VHPT is enabled vs. ~900 cycles with VHPT disabled and handling the
TLB miss in the IVT. Does anybody know if the VHPT walker is implemented in hardware (probably
not), microcode (that's what I think) or unimplemented at all?

Christian


