From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 11 Jan 2002 21:33:29 +0000
Subject: RE: [Linux-ia64] latest MCA logging patch
Message-Id: <marc-linux-ia64-105590698805812@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805745@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805745@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 11 Jan 2002 13:25:40 -0800, "Mallick, Asit K" <asit.k.mallick@intel.com> said:

  Asit> David, SAL re-entrancy issue was primarily observed with
  Asit> SAL_PCI_READ/WRITE_CONFIG in very early firmwares and earlier
  Asit> kernels. However, this re-entrancy problem is fixed with the
  Asit> use of the pci_lock.

If the pci_lock is sufficient for SAL_PCI_READ/WRITE_CONFIG, we can
remove it for those two cases (with a comment to that effect).  I
don't really see much point in doing this though.  It's not like this
is a performance critical operation.

  Asit> Other SAL calls are used during the
  Asit> initialization time and should have re-entrancy
  Asit> problem. Anyway, Jenna is checking with FW team on re-entrancy
  Asit> and will provide the FW versions.

Will you check only for Intel firmware or all IA-64 firmware in
existence?  The original SAL spec did not require re-entrancy and I
don't think it's safe to remove the lock unless we know for sure that
all existing implementations have been fixed (or are no longer in
use).

	--david

