From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 19 Aug 2003 00:16:05 +0000
Subject: Re: ia64 2.6.0-test3 crashes on IOZone
Message-Id: <marc-linux-ia64-106125238528418@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106098668517415@msgid-missing>
In-Reply-To: <marc-linux-ia64-106098668517415@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 18 Aug 2003 17:12:29 -0700, Evan Felix <evan.felix@pnl.gov> said:

  Evan> I tired not to do anything strange,  i place the .config at
  Evan> http://felix.homeip.net/2.6.config  if you wouldn't mind taking a look.

It looks mostly fine to me.  I see several SCSI drivers are enabled.
Which one actually talks to the test disk?  SYM53C8XX_2?

One thing I did notice: It's configured for Itanium (Merced) instead
of Itanium 2.  That will definitely slow things down, though the
resulting kernel should work correctly.  I'd recommend to change that
to Itanium 2 (McKinley).

	--david
