From: Al Stone <ahs3@ahs3.net>
Date: Mon, 13 Aug 2007 04:27:18 +0000
Subject: Ski -- the ia64 CPU simulator -- is now open source
Message-Id: <46BFDDA6.7070005@ahs3.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Greetings.

After much hullabaloo, and a bit of pounding on the code, the Ski ia64
instruction set simulator is now available as open source, thanks to the
efforts of the folks at HP.

For those that have never heard of Ski, it was originally written by the
Hewlett-Packard Company.  It simulates the IA-64 architecture as defined
by the Intel Itanium 2 architecture manuals.  This is not a full
platform simulator; i.e., no system chipset or PCI bus simulation is
done.  However, Ski supports the full instruction set of the
architecture, including privileged instructions and associated
semantics.

While the Ski binaries have been available from HP for quite some time,
this is the first time that the source has been made available.

You can find Ski at http://ski.sourceforge.net

As always, patches and corrections are welcome...

-- 
Ciao,
al
----------------------------------------------------------------------
Al Stone                                      Alter Ego:
E-mail: ahs3@ahs3.net                         Debian Developer
  -or-                                         http://www.debian.org
E-mail: ahstone@comcast.net                   ahs3@debian.org
----------------------------------------------------------------------
