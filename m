From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 27 Feb 2004 18:52:46 +0000
Subject: Re: [PATCH] sal cleanup
Message-Id: <16447.37374.350498.666550@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 26 Feb 2004 22:04:56 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> On Thu, Feb 26, 2004 at 01:55:34PM -0800, David Mosberger
  Matthew> wrote:
  >> How about printing "none" or something like that instead?

  Matthew> Sure.


  Matthew> This patch reorganises sal.c and adds two new functions:

  Matthew>  - Split the body of the switch statement in
  Matthew> ia64_sal_init() into separate functions.  - Delete min/max
  Matthew> since they were only assigned to, never used.  - Print the
  Matthew> version of the SAL implementation as well as the spec
  Matthew> version it supports.  - Stop printing the pal_proc and
  Matthew> sal_proc entry addresses.  - Print "none" if there are no
  Matthew> platform features.  - Remember the sal revision and version
  Matthew> and add two functions to compare them.

The patch also changes the arguments for ia64_sal_pci_config_read()
and ia64_sal_pci_config_write(), without changing any callers.
Why?

Also, how about putting a colon after "SAL Platform features"?

	--david
