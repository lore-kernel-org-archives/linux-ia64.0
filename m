From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 15 Apr 2004 05:11:30 +0000
Subject: Re: kernel update (relative to 2.6.5)
Message-Id: <16510.6530.787181.529586@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200404140103.i3E13cB0004406@napali.hpl.hp.com>
In-Reply-To: <200404140103.i3E13cB0004406@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 15 Apr 2004 12:54:12 +1000, Martin Pool <mbp@sourcefrog.net> said:

  Martin> On Wed, 14 Apr 2004 13:59:24 +0200, Andreas Schwab wrote:
  >> Martin Pool <mbp@sourcefrog.net> writes:
  >> 
  >>> On Wed, 14 Apr 2004 16:22:28 +1000, Martin Pool wrote:
  >>> 
  >>>> *** Warning: "per_cpu__local_per_cpu_offset"
  >>>> [drivers/net/yellowfin.ko] has no C RC!
  >>>  Please disregard my message, this seems not to be caused by
  >>> your patch.
  >>
  >> http://marc.theaimsgroup.com/?l=linux-kernel&m6570613115664&w=2

  Martin> Thanks for that.  Your patch fixes it for me too.  Maybe it
  Martin> could be merged into David's tree?

I don't like to clutter the ia64 patch with stuff that has
nothing/little to do with ia64.  Why isn't this patch in the Linus'
tree yet?

	--david
