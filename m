From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 15 Feb 2007 12:15:54 +0000
Subject: fault-injection framework on ia64
Message-Id: <20070215041554.8e9c92aa.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


lib/built-in.o(.text+0x2c192): In function `should_fail':
: undefined reference to `save_stack_trace'

We could disable the feature on ia64, but then they wouldn't be able to
inject faults.

