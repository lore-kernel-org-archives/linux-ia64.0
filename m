From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 05 Dec 2003 04:15:11 +0000
Subject: Re: can't boot 2.6.0-test11
Message-Id: <marc-linux-ia64-107059775624855@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107057525104512@msgid-missing>
In-Reply-To: <marc-linux-ia64-107057525104512@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 4 Dec 2003 21:37:46 -0500, Bill Nottingham <notting@redhat.com> said:

  Bill> David Mosberger (davidm@napali.hpl.hp.com) said: Comparing
  Bill> readelf output, one big difference is where it loads the
  Bill> percpu data segment:
  >>  That should be OK though.  elilo only ever looks at the physical
  >> addresses.  Do you have a stale version of elilo by chance?

  Bill> No, 3.4.

Very odd.  It's most likely something in the toolchain, elilo, or
something in-between, but I can't think of what it is that might be
biting you.  Stephane probably can give you better suggestions on
turning on debug printing in elilo so you can see what's going on.

	--david
