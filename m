From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 29 Apr 2005 11:42:08 +0000
Subject: RE: gate page oops
Message-Id: <17010.7568.775064.65612@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.61.0504221524590.31361@dhcp83-105.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 26 Apr 2005 13:10:06 -0400 (EDT), Jason Baron <jbaron@redhat.com> said:

  Jason> On Fri, 22 Apr 2005, Luck, Tony wrote:

  >> The gate page only needs to be PAGE_SIZE ... doesn't it?

  Jason> I'm not really sure...i was hoping somebody on the list would
  Jason> know :) If you look at setup_gate(), it establishes two gate
  Jason> pages, the comment says:

  Jason> * Map the gate page twice: once read-only to export the ELF
  Jason> headers etc. and once * execute-only page to enable
  Jason> privilege-promotion via "epc":

  Jason> So the patch i proposed was intended to allow user access to
  Jason> these two regions. Currently, that isn't being done properly,
  Jason> leading to an oops.

Yes, IIRC, we need to give ptrace() access to the execute-only page so
that a debugger can read and decode the instruction at the address
(yes, that circumvents the execute-only part of the mapping, but we
don't really care about that; the only reason it's execute-only is
because that's the only way to get the promote-privilege-on-epc
behavior).

	--david
