From: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Date: Thu, 29 Jan 2004 22:20:21 +0000
Subject: Re: [RFC/PATCH, 1/4] readX_check() performance evaluation
Message-Id: <200401292220.i0TMKbnA034623@mtv-vpn-hw-mfl-2.corp.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <16409.30329.336793.50051@napali.hpl.hp.com> from "David Mosberger" at Jan 29, 2004 01:09:13 PM
References: <00a201c3e541$c0e7d680$2987110a@lsd.css.fujitsu.com>
In-Reply-To: <00a201c3e541$c0e7d680$2987110a@lsd.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>, Andi Kleen <ak@suse.de>, davidm@napali.hpl.hp.com, iod00d@hp.com, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>   Matthias> We have done a rather large study with DIMMs that had SBEs
>   Matthias> I should have been more precice. We used field returned
>   Matthias> parts which had reported SBEs and had been exchanged in
>   Matthias> the field. Our goal was to see if any of these parts
>   Matthias> "de-generate" over time. Most of these parts had hard
>   Matthias> single bit failures in one or more locations.
> 
> Ah, that's more interesting, agreed.
> 
>   Matthias> As I said, we didn't find evidence that even hard SBEs
>   Matthias> turn into a multiple bit error.
> 
> But you were changing the operating environment of the chip, so I
> wouldn't draw too strong of a conclusion.  Or was the reason for the
> hard SBEs known and it was determined that the operating environment
> was not a factor in triggering them?

That is a very good point and one of my favourite subjects. I think
a lot of error checking has to be done in-flight, i.e. at the time of
the error check if the error is transient or can be reproduced, if possible
log environmental information (temp and VDD) with the error etc.
And then have a small EEPROM on standard DIMMs and save this error information,
so we don't rely on paper tags. Or maybe include the DIMM serial number
in the error message. But I'm getting carried away :)

As for the test environment, a fair amount of DIMMs was put through 
environmental stress ("shake & bake") as well as extended voltage margins.
(I remain impressed with these chambers where you can dial down from +60C to
 -40C within a few minutes while the system is vibrating with a couple of G's)
We actually exceeded the DIMM manufacturers specifications for limits,
again no sign of increased failure rate for DIMMs with SBEs.

Some failure modes are very complex and data pattern sensitive.

As someone pointed out quite correctly, there is a fine line how much
information should be logged and potentialy ring a bell for the customer
to place a service call to replace a part which potentially will never
fail again (again there is a difference between a hard and a soft error).

One option might be to have a separate error log, so the console is not
overflowed with messages and then use some tool to diagnose the errors
and potentially warn the user, i.e. turn on the "check engine" light.
We should keep the average user in mind

Thanks

Matthias Fouquet-Lapar  Core Platform Software    mfl@sgi.com  VNET 521-8213
Principal Engineer      Silicon Graphics          Home Office (+33) 1 3047 4127

