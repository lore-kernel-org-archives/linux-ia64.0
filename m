From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 29 Jan 2004 21:09:13 +0000
Subject: Re: [RFC/PATCH, 1/4] readX_check() performance evaluation
Message-Id: <16409.30329.336793.50051@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16409.24257.589224.818006@napali.hpl.hp.com>
	<200401292016.i0TKGraI034387@mtv-vpn-hw-mfl-2.corp.sgi.com>
In-Reply-To: <200401292016.i0TKGraI034387@mtv-vpn-hw-mfl-2.corp.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com>
Cc: davidm@hpl.hp.com, Andi Kleen <ak@suse.de>, davidm@napali.hpl.hp.com, iod00d@hp.com, ishii.hironobu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> On Thu, 29 Jan 2004 21:16:52 +0100 ("CET), Matthias Fouquet-Lapar <mfl@kernel.paris.sgi.com> said:

  Matthias> We have done a rather large study with DIMMs that had SBEs
  Matthias> I should have been more precice. We used field returned
  Matthias> parts which had reported SBEs and had been exchanged in
  Matthias> the field. Our goal was to see if any of these parts
  Matthias> "de-generate" over time. Most of these parts had hard
  Matthias> single bit failures in one or more locations.

Ah, that's more interesting, agreed.

  Matthias> As I said, we didn't find evidence that even hard SBEs
  Matthias> turn into a multiple bit error.

But you were changing the operating environment of the chip, so I
wouldn't draw too strong of a conclusion.  Or was the reason for the
hard SBEs known and it was determined that the operating environment
was not a factor in triggering them?

	--david
