From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 08 Jun 2004 21:38:43 +0000
Subject: Re: Scalability enhancements for gettimeofday
Message-Id: <16582.12771.356969.526686@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405201205.57930.clameter@sgi.com>
In-Reply-To: <200405201205.57930.clameter@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 8 Jun 2004 11:32:46 -0700 (PDT), Christoph Lameter <christoph@lameter.com> said:

  Christoph> This does not effect the update of last_itc which does
  Christoph> not depend on any of the variables you mention. The
  Christoph> dependency existed for last_nsec_offset but does NOT
  Christoph> exist for last_itc. There is much more than just a name
  Christoph> change going on.

Let me try this again: the second you update a global variable with a
bogus/inconsistent value, another CPU may observe that value.  The
fact that you're going to try to correct that bad value later on
doesn't help you at all.  See the problem now?

The fundamental issue is that with ITC-based interpolation, reading
the offset has a side-effect, which isn't true for global-timer-based
interpolation.  Hence the need for a two-phase protocol.

	--david
