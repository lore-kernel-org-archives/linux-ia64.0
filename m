From: Gerrit Huizenga <gh@us.ibm.com>
Date: Wed, 06 Apr 2005 05:15:18 +0000
Subject: Re: [PATCH] add a clear_pages function to clear pages of higher order
Message-Id: <E1DJ2sp-0004jm-00@w-gerrit.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of Tue, 05 Apr 2005 21:48:22 PDT.
             <16979.27158.381388.691910@napali.hpl.hp.com> 
References: <Pine.LNX.4.58.0503161720570.1787@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0503161720570.1787@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Christoph Lameter <clameter@engr.sgi.com>, Andi Kleen <ak@muc.de>, Christoph Lameter <clameter@sgi.com>, Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>, Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, linux-ia64@vger.kernel.org, Jens.Maurer@gmx.net


On Tue, 05 Apr 2005 21:48:22 PDT, David Mosberger wrote:
> >>>>> On Tue, 5 Apr 2005 17:33:59 -0700 (PDT), Christoph Lameter <clameter@engr.sgi.com> said:
> 
>   Christoph> Which benchmark would you recommend for this?
> 
> I don't know about "recommend", but I think SPECweb, SPECjbb,
> the-UNIX-multi-user-benchmark-whose-name-I-keep-forgetting, and in
> general anything that involves process-activity and/or large working
> sets might be interesting (in other words: anything but
> microbenchmarks; I'm afraid).

SpecSDET, Aim7 or ReAim from OSDL are probably what you are thinking
of.

gerrit
