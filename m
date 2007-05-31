From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 31 May 2007 20:51:22 +0000
Subject: [PATCH] microcode: fix section mismatch warning
Message-Id: <20070531205122.GG27305@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A01929DD3@scsmsx411.amr.corp.intel.com> <Pine.LNX.4.64.0705302019040.5583@schroedinger.engr.sgi.com> <465EE7BB.4050605@redhat.com> <20070531200446.GA27305@uranus.ravnborg.org>
In-Reply-To: <20070531200446.GA27305@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Prarit Bhargava <prarit@redhat.com>, tigran@aivazian.fsnet.co.uk
Cc: Christoph Lameter <clameter@sgi.com>, "Luck, Tony" <tony.luck@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Fix the following section mismatch warnings in microcode.c:
WARNING: arch/i386/kernel/built-in.o(.init.text+0x3966): Section mismatch: reference to .exit.text: (between 'microcode_init' and 'parse_maxcpus')
WARNING: arch/i386/kernel/built-in.o(.init.text+0x3992): Section mismatch: reference to .exit.text: (between 'microcode_init' and 'parse_maxcpus')

The warning are caused by a function marked __init that
calls a function marked __exit.
Functions marked __exit may be discarded either during link or run-time
and thus the reference is not good.

Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
---
diff --git a/arch/i386/kernel/microcode.c b/arch/i386/kernel/microcode.c
index 83f825f..d865d04 100644
--- a/arch/i386/kernel/microcode.c
+++ b/arch/i386/kernel/microcode.c
@@ -478,7 +478,7 @@ static int __init microcode_dev_init (void)
 	return 0;
 }
 
-static void __exit microcode_dev_exit (void)
+static void microcode_dev_exit (void)
 {
 	misc_deregister(&microcode_dev);
 }
