From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Thu, 29 Jan 2004 20:16:52 +0000
Subject: Re: [RFC/PATCH, 1/4] readX_check() performance evaluation
Message-Id: <200401292016.i0TKGraI034387@mtv-vpn-hw-mfl-2.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <16409.24257.589224.818006@napali.hpl.hp.com> from "David Mosberger" at Jan 29, 2004 11:28:01 AM
References: <00a201c3e541$c0e7d680$2987110a@lsd.css.fujitsu.com>
In-Reply-To: <00a201c3e541$c0e7d680$2987110a@lsd.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>, Andi Kleen <ak@suse.de>, davidm@napali.hpl.hp.com, iod00d@hp.com, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>   Matthias> We have done a rather large study with DIMMs that had SBEs
>   Matthias> and have found no evidence that a SBE turns into a UCE,
>   Matthias> i.e. the fact that a SBE is reported, is no indication
>   Matthias> that the device might fail soon.
> 
> Ehh, wait a second: you're saying that your study proved that if the
> device isn't failing, it isn't failing. ;-) Of course you'll get noise

I should have been more precice. We used field returned parts which 
had reported SBEs and had been exchanged in the field. Our goal was to
see if any of these parts "de-generate" over time. Most of these parts
had hard single bit failures in one or more locations. As I said,
we didn't find evidence that even hard SBEs turn into a multiple bit
error. Of course the chances of getting a UCE are higher when a "soft"
SBE occurs in a memory location which already has a hard SBE.


Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

