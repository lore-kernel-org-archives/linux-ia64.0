From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 17 Sep 2001 16:53:57 +0000
Subject: Re: [Linux-ia64] PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805194@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805193@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805193@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 17 Sep 2001 10:02:14 -0600, Doug Beattie <dbb@caldera.com> said:

  Doug> Your reponse is welcome and invited.  The LSB and FHS groups
  Doug> are trying to better address the coexistance of 32 and 64 bit
  Doug> in the 64 bit Itanium environment.

  Doug> Please review the following proposal and respond to the
  Doug> "lsb-spec@lists.linuxbase.org" and
  Doug> "lsb-discuss@lists.linuxbase.org" mail lists.

When will people learn that for Linux, source compatibility is just as
important as binary compatibility?  For IA-64 Linux, the decision was
made that native libraries go into /lib etc and that legacy libraries
go somewhere else (/usr/i386-*-linux/lib, commonly).

	--david

