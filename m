From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 27 Jan 2004 21:57:08 +0000
Subject: Re: bk pull on ia64 linux tree
Message-Id: <16406.57012.673701.362269@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 27 Jan 2004 05:23:22 -0500, Jes Sorensen <jes@wildopensource.com> said:

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:
  David> Hi Linus, please do a

  David> bk pull http://lia64.bkbits.net/to-linus-2.5

  David> This will update the files shown below (only ia64-specific
  David> files are touched).

  Jes> Is this patch available as a normall diff somewhere?

I don't make real patches for release-candidates, but in theory, you
should be able to get the equivalent patch from:

  http://www.kernel.org/pub/linux/kernel/ports/ia64/v2.6/testing/cset/

In practice, it appears that the script that's supposed to create this
was failing.  I fixed this now and the URL is working again.

	--david
