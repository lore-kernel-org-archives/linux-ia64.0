From: "H. J. Lu" <hjl@lucon.org>
Date: Fri, 21 May 2004 17:08:20 +0000
Subject: Can gcc 3.4 compile 2.6.6 kernel?
Message-Id: <20040521170820.GA5516@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Has anyone tried to use gcc 3.4 to compile 2.6.6 kernel? I got many
dependency violation messages from assembler and

mm/memory.c: In function `copy_page_range':
mm/memory.c:391: internal compiler error: in verify_local_live_at_start, at
flow.c:546
Please submit a full bug report,
with preprocessed source if appropriate.
See <URL:http://gcc.gnu.org/bugs.html> for instructions.

Also does 2.6.6 work on bigsur?


H.J.
