From: Ville Herva <vherva@niksula.hut.fi>
Date: Fri, 07 Dec 2001 08:10:07 +0000
Subject: [Linux-ia64] eepro100 hang?
Message-Id: <marc-linux-ia64-105590698805637@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

at http://linuxia64.org/todo.html, it says 

  EEPro100 ? Hangs on >180MB xfers

Is this supposed to be fixed?

Mandrake ftp installation stalled in the middle, and when I straced the
process from shell, it seemed to be loading rpm from ftp server, but the
read always returned 1 byte, and and it took about half a second to do so.

On second run it stalled as well, but in another place. I kill -HUP'ed the
download, and the rest went fine.

After installation, I can scp a 650MB image just fine, but that's from local
network.

I dig any deeper yet.

HP i2000, eepro100.


-- v --

v@iki.fi

