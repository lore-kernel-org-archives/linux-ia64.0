From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Thu, 29 Jan 2004 08:23:20 +0000
Subject: Re: [RFC/PATCH, 1/4] readX_check() performance evaluation
Message-Id: <200401290823.i0T8NTDi024477@mtv-vpn-hw-mfl-2.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <16408.3157.336306.812481@napali.hpl.hp.com> from "David Mosberger" at Jan 28, 2004 11:24:05 AM
References: <00a201c3e541$c0e7d680$2987110a@lsd.css.fujitsu.com>
In-Reply-To: <00a201c3e541$c0e7d680$2987110a@lsd.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Andi Kleen <ak@suse.de>, davidm@napali.hpl.hp.com, iod00d@hp.com, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>   Andi> e.g. one bit ECC errors in memory are quite common.  And with
>   Andi> ECC memory they are not really fatal.
> 
> Yet they are a good indicator that something is wrong (not performing
> properly) or may be failing soon.  I don't think putting on blinders
> for such problems is a good idea.  Though I agree that the question of
> how to report such things without needlessly alerting Joe Clueless is
> an interesting challenge.

We have done a rather large study with DIMMs that had SBEs and have
found no evidence that a SBE turns into a UCE, i.e. the fact that a SBE is
reported, is no indication that the device might fail soon.

As a matter of fact the soft error rates increases while parts use
smaller process technologies and lower supply voltages. Cosmic rays
are one source for soft errors. Another source are alpha particles
emitted by the solder.

Still I think it's important to log SBEs, but you probably will need
a treshhold in case you hit a hard SBE. Also scrubbing the memory location
(and re-read the location to check if the error was transient or not)
might be a good idea if the memory controller supports this.
If it is a true, hard SBE it should be reported. It also might be a good
idea to mark the page, so it does not get re-allocated. 


Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

