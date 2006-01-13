From: Keith Owens <kaos@sgi.com>
Date: Fri, 13 Jan 2006 00:46:29 +0000
Subject: Preserving CMC/CPE records across reboot
Message-Id: <14947.1137113189@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

CMC/CPE records (unlike MCA/INIT) are copied into kernel space and
cleared from NVRAM as soon as they occur.  That decision was made by
Bjorn Helgaas some years ago.  The idea is that if you do not have
salinfo_decode or some equivalent program running then the correctable
errors still need to be deleted from NVRAM.  But if the system hangs
while reading the CMC/CPE then we get no data at all.

SGI just had an example of this.  A cpu took a CMC, salinfo_decode
started running and hung while processing the CMC record, the system
had to be rebooted.  Because the CMC record had been cleared from NVRAM
before handing a copy to salinfo_decode, the contents were lost.

We should be able to keep the first few CMC/CPE records for each cpu in
NVRAM and discard the later ones if we start getting a backlog.  Then
if the system hangs while processing a CMC/CPE, the data will still be
available in NVRAM and will be processed on the next boot.  If the
reboot hangs again in salinfo processing then we have a solid error,
either cpu or SAL, so switch the offending cpu out of the system.

Any objections from other platforms?

