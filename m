From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 18 Sep 2002 06:54:13 +0000
Subject: [Linux-ia64] kernel update (relative to 2.5.35)
Message-Id: <marc-linux-ia64-105590701906038@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A new ia64 patch is now at ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.5/
in file:

	linux-2.5.35-ia64-020917.diff.gz

Most important changes:

	- added Rohit's huge page patch (now you too can have 4GB
          pages... ;-)
	- new clone() flags are (should be) supported now

See http://lia64.bkbits.net:8080/to-linus-2.5 for a more detailed
change log.

Seems to work fine on HP Ski and Big Sur.  It's not working on zx1
machines at the moment (I'll fix that next, but that will probably be
with 2.5.36 or wherever Linus is by then...)

Enjoy,

	--david

