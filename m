From: Stephane Eranian <eranian@hpl.hp.com>
Date: Tue, 13 Nov 2007 22:34:01 +0000
Subject: perfmon Itanium 9100 series support (Montvale)
Message-Id: <20071113223401.GI5747@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello everyone,

Intel released the Itanium 9100 series (Montvale) a few days ago.

My understanding is that the Montvale PMU is fully compatible with
the Montecito PMU (dual-core Itanium 9000 series). Thus, there will
not be any patches needed neither at the kernel level, nor in libpfm
or pfmon to support this new processor.

Those comments hold true for the mainline perfmon (v2.0) and
the development perfmon in GIT (v2.7).

Thanks.

-- 
-Stephane
