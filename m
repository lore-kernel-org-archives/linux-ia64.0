From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 29 Jan 2004 19:28:01 +0000
Subject: Re: [RFC/PATCH, 1/4] readX_check() performance evaluation
Message-Id: <16409.24257.589224.818006@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16408.3157.336306.812481@napali.hpl.hp.com>
	<200401290823.i0T8NTDi024477@mtv-vpn-hw-mfl-2.corp.sgi.com>
In-Reply-To: <200401290823.i0T8NTDi024477@mtv-vpn-hw-mfl-2.corp.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Cc: davidm@hpl.hp.com, Andi Kleen <ak@suse.de>, davidm@napali.hpl.hp.com, iod00d@hp.com, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> On Thu, 29 Jan 2004 09:23:20 +0100 ("CET), Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com> said:

  Matthias> We have done a rather large study with DIMMs that had SBEs
  Matthias> and have found no evidence that a SBE turns into a UCE,
  Matthias> i.e. the fact that a SBE is reported, is no indication
  Matthias> that the device might fail soon.

  Matthias> As a matter of fact the soft error rates increases while
  Matthias> parts use smaller process technologies and lower supply
  Matthias> voltages. Cosmic rays are one source for soft
  Matthias> errors. Another source are alpha particles emitted by the
  Matthias> solder.

Ehh, wait a second: you're saying that your study proved that if the
device isn't failing, it isn't failing. ;-) Of course you'll get noise
and perhaps even lots of it due to cosmic rays but this doesn't say
anything about the error pattern you when a device _is_ failing (e.g.,
due to overheating, over-clocking, or wrong voltage).  Or did your
study cover the cases where a system is operated under "out-of-spec"
situation?

  Matthias> Still I think it's important to log SBEs, but you probably
  Matthias> will need a treshhold in case you hit a hard SBE. Also
  Matthias> scrubbing the memory location (and re-read the location to
  Matthias> check if the error was transient or not) might be a good
  Matthias> idea if the memory controller supports this.  If it is a
  Matthias> true, hard SBE it should be reported. It also might be a
  Matthias> good idea to mark the page, so it does not get
  Matthias> re-allocated.

Yes.  And once I finally received Andi's earlier mails (guess I have
to thank MyDoom for that... ;-( ), it was clear that nobody argued for
turning off the error reporting.  The issue was only whether or not to
log a message via printk() (which, in this case, clearly isn't a good
idea).  So I think we're all in violent agreement.

	--david
