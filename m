From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 17 Oct 2000 18:42:40 +0000
Subject: Re: [Linux-ia64] Instruction Execution
Message-Id: <marc-linux-ia64-105590678205580@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205577@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205577@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Instruction timing depends on what instructions you are executing, and where
the stop bits are.  If you are running a loop with FP instructions, or a loop
with a lot of serial instruction dependencies, then 1 cycle per instruction
is certainly possible.  Since you didn't give any assembly code samples,
it isn't possible to tell if the loop was poorly optimized or not.

Jim

