From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 16 Aug 2003 04:52:43 +0000
Subject: Re: ia64 2.6.0-test3 crashes on IOZone
Message-Id: <marc-linux-ia64-106100957729925@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106098668517415@msgid-missing>
In-Reply-To: <marc-linux-ia64-106098668517415@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 15 Aug 2003 15:37:39 -0700, Evan Felix <evan.felix@pnl.gov> said:

  Evan> Recently i've been trying to run linux 2.6.0-test3 on a HP
  Evan> zx2000, I've run IOZone twice on the system and both times it
  Evan> has crashed with:

  Evan> pdflush[546]: General Exception: IA-64 Reserved Register/Field
  Evan> fault (data acce]

I can't reproduce that (2.6.0-test3 + ia64 patch).  I also ran it
twice with the same arguments and it ran to completion both times.

What compiler do you use?

	--david
