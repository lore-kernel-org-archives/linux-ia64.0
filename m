From: Fons Rademakers <Fons.Rademakers@cern.ch>
Date: Mon, 09 Dec 2002 14:33:37 +0000
Subject: [Linux-ia64] backtrace()...
Message-Id: <marc-linux-ia64-105590709805519@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

  I try to use backtrace() (/usr/include/execinfo.h) but it returns
nothing meaningfull (one 0 stackframe). This is on Itanium2:

Kernel 2.4.18-e.4smp
glibc-2.2.4-29.2

Is this expected or should I do something special?

Cheers, Fons.

-- 
Org:    CERN, European Laboratory for Particle Physics.
Mail:   1211 Geneve 23, Switzerland
E-Mail: Fons.Rademakers@cern.ch              Phone: +41 22 7679248
WWW:    http://root.cern.ch/~rdm/            Fax:   +41 22 7679480

