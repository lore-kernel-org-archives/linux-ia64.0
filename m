From: "Robboy, David G" <david.g.robboy@intel.com>
Date: Tue, 03 Jul 2001 23:41:13 +0000
Subject: [Linux-ia64] Inquiry on the pre-processor
Message-Id: <marc-linux-ia64-105590693005816@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The C preprocessor doesn't recognize macros that are suffixed on words.  It
likes to substitute whole words. Does anyone know a trick to get it to
substitute text for suffixes?  Someone has to have done this before.

What I want to do specifically is for ia32 assembly language, but the
question is about preprocessing in general.  On certain assembly instruction
opcodes, I want to suffix a macro that can be changed to the letter "b,"
"w," or "l," so that a single source program can operate on different sized
operands. 

Thanks,
David Robboy


