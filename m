From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 04 Aug 2004 08:31:58 +0000
Subject: Re: Timer updates revision 7 (asm sets predicates/various fixes)
Message-Id: <16656.40702.214274.248505@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0407292044500.3633@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0407292044500.3633@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 3 Aug 2004 14:06:26 -0700 (PDT), Christoph Lameter <christoph@lameter.com> said:

  >>  No, I think they're precisely because you linked the program
  >> dynamically.  Try linking it statically.  I'm fairly confident
  >> you'll get the same/very similar numbers as I did.

  Christoph> When I link it statically the fastcall handler is not
  Christoph> used and the numbers are much higher. Maybe we are using
  Christoph> different glibcs? This is with SUSE SLES9.

Ah, I see.  I'm using a glibc which I compiled a while ago from the
glibc CVS tree.

	--david
