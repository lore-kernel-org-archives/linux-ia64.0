From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 07 Dec 2001 16:16:43 +0000
Subject: Re: [Linux-ia64] eepro100 hang?
Message-Id: <marc-linux-ia64-105590698805643@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805637@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805637@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 7 Dec 2001 10:10:07 +0200, Ville Herva <vherva@niksula.hut.fi> said:

  Ville> at http://linuxia64.org/todo.html, it says EEPro100 ? Hangs
  Ville> on >180MB xfers

  Ville> Is this supposed to be fixed?

I don't think the workstations (i2000) ever suffered from this problem.
It appeared only on the 4-way server.

  Ville> Mandrake ftp installation stalled in the middle, and when I
  Ville> straced the process from shell, it seemed to be loading rpm
  Ville> from ftp server, but the read always returned 1 byte, and and
  Ville> it took about half a second to do so.

  Ville> On second run it stalled as well, but in another place. I
  Ville> kill -HUP'ed the download, and the rest went fine.

  Ville> After installation, I can scp a 650MB image just fine, but
  Ville> that's from local network.

  Ville> I dig any deeper yet.

  Ville> HP i2000, eepro100.

For what it's worth, I use an i2000 with an eepro100 all the time and
haven't seen any hangs.  Of course, that doesn't prove anything; just
a data point...

	--david

