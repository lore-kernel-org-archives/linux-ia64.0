From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 24 Jul 2001 09:09:38 +0000
Subject: [Linux-ia64] heads up: ucd-snmp 64-bit problem
Message-Id: <marc-linux-ia64-105590693005894@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just a quick note: I discovered that there are some ugly 64-bit
dirtiness issues in the UCD snmp package.  It seems that Bill has
fixed some of them already, but even with the "rawhide" version of
ucd-snmp-utils, setting an IP address doesn't work.  For example, a
command along the lines of:

 $ snmpset aws110 public .enterprises.410.1.1.2.1.0 a 192.168.1.10

would fail because "snmpset" tries to write the IP address as an eight
byte quantity.  I hope someone who's more familiar with SNMP can fix
this.

	--david

