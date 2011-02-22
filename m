From: "Jan Beulich" <JBeulich@novell.com>
Date: Tue, 22 Feb 2011 08:26:59 +0000
Subject: [PATCH, v2 0/3] generalize exception table implementation to
Message-Id: <4D6381630200007800033136@vpn.id2.novell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mingo@elte.hu, tony.luck@intel.com, tglx@linutronix.de, hpa@zytor.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

This will allow x86-64 to shrink its exception tables by half, and ia64 to
drop its custom implementation.

v2: Adjust arch/x86/kernel/test_nx.c (leading to some tests no longer
    getting run on x86-64) and indent some pre-processor directives in
    patch #2.

1/3: x86-64: use macros to generate exception table entries
2/3: x86-64: use relative 32-bit pointers in exception tables
3/3: ia64: drop custom exception table implementation

Signed-off-by: Jan Beulich <jbeulich@novell.com>

