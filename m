From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 02 Mar 2004 18:01:28 +0000
Subject: Re: [PATCH] sal cleanup
Message-Id: <16452.52216.542759.941632@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040226213704.GW25779@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 2 Mar 2004 17:57:01 +0000, Matthew Wilcox <willy@debian.org> said:

  Matthew> Yeah.  That's why I moved it into a separate function so we
  Matthew> can add other bad version numbers.  If we were really keen,
  Matthew> we could even add a check for the oem and product IDs
  Matthew> matching, or a data table of known-bad BIOSes but let's
  Matthew> keep it simple until we have to make it complex.

Well, I can live with either approach, so it's your call.  It's just that
a command-line option can come in handy when you're urgently trying to boot
a kernel and you can't rebuild a kernel (like when trying to demo a new
machine... ;-).

  Matthew> SAL_VERSION_CODE(49, 29)

  >>  shouldn't these be in hex?

  Matthew> Nope, that's the beauty of it:

  Matthew> #define SAL_VERSION_CODE(major, minor) ((BIN2BCD(major) <<
  Matthew> 8) | BIN2BCD(minor))

  Matthew> BIN2BCD is defined in linux/bcd.h as ((((val)/10)<<4) +
  Matthew> (val)%10)

  Matthew> So you get to specify things in decimal.

Ah, I missed that.  Nice.

	--daivd
