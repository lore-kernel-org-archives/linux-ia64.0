From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 07 Jul 2004 05:34:36 +0000
Subject: `PCDP_TABLE_GUID' undeclared
Message-Id: <16619.35692.503174.993123@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I get this error when compiling pcdp.c with CONFIG_IA64_EARLY_PRINTK_UART
enabled.  s/PCDP_TABLE_GUID/HCDP_TABLE_GUID/?

	--david

