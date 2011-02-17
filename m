From: "Jan Beulich" <JBeulich@novell.com>
Date: Thu, 17 Feb 2011 17:02:05 +0000
Subject: [PATCH 0/3] generalize exception table implementation to deal
Message-Id: <4D5D629D02000078000327E1@vpn.id2.novell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mingo@elte.hu, tony.luck@intel.com, tglx@linutronix.de, hpa@zytor.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

This will allow x86-64 to shrink its exception tables by half, and ia64 to
drop its custom implementation.

1/3: x86-64: use macros to generate exception table entries
2/3: x86-64: use relative 32-bit pointers in exception tables
3/3: ia64: drop custom exception table implementation

Signed-off-by: Jan Beulich <jbeulich@novell.com>

