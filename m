From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 09 Jul 2003 15:27:21 +0000
Subject: RE: Reliably creating MCA on white box Itanium-1
Message-Id: <marc-linux-ia64-105776474800987@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105721395828393@msgid-missing>
In-Reply-To: <marc-linux-ia64-105721395828393@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Seems to me that a TLB error caused by a duplicate TR dropin 
> *should* call
> C code.  A MCA caused by a duplicate TR is a software bug that should
> panic the system. 
> 
> I understand that TLB parity errors would be silently 
> corrected in mca_asm.S
> by reloading the TLB. 

The patch that I posted recently (June 25th) for recovery
from TLB MCA errors (for 2.4 ... version for 2.5 will be
out soon).  Should do what you want.  The assembly code checks
the "processor state parameter" to see if there was a TLB
error, if there is, then it fixes it by purging the TLB and
reloading ITR[0,1], DTR[0,1,2].  It then calls the C-code
handler (in case there are other errors in the same MCA, and
to give the upper level code an opportunity to do whatever
logging it wants to do).

-Tony
