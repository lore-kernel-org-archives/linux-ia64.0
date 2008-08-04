From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 04 Aug 2008 19:27:25 +0000
Subject: RE: [Patch 2/2] update generic_defconfig to support sn2.
Message-Id: <57C9024A16AD2D4C97DC78E552063EA308328F06@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080802183527.GA7290@sgi.com>
In-Reply-To: <20080802183527.GA7290@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've locally applied these config updates, but I ran into
a regression while running my usual set of test builds.

I build a few uniprocessor configs (by taking files from
arch/ia64/configs/ and turning off CONFIG_SMP).  The
resulting uniprocessor generic_defconfig fails to
build with:

drivers/misc/sgi-gru/grutables.h:308: error: field `ms_notifier' has incomplete type

I tried this:
diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index 82af385..6e2dcd8 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -430,7 +430,7 @@ config SGI_XP
        depends on IA64_GENERIC || IA64_SGI_SN2 || IA64_SGI_UV || (X86_64 && SMP)
        select IA64_UNCACHED_ALLOCATOR if IA64_GENERIC || IA64_SGI_SN2
        select GENERIC_ALLOCATOR if IA64_GENERIC || IA64_SGI_SN2
-       select SGI_GRU if IA64_GENERIC || IA64_SGI_UV || (X86_64 && SMP)
+       select SGI_GRU if (IA64_GENERIC || IA64_SGI_UV || X86_64) && SMP
        ---help---
          An SGI machine can be divided into multiple Single System
          Images which act independently of each other and have

As an obvious fix (if SMP is required on X86, then surely it is
also required for other arches too).  But that just let the build
get a bit further until here:

  Building modules, stage 2.
  MODPOST 163 modules
ERROR: "gru_free_message" [drivers/misc/sgi-xp/xpc.ko] undefined!
ERROR: "gru_get_next_message" [drivers/misc/sgi-xp/xpc.ko] undefined!
ERROR: "gru_send_message_gpa" [drivers/misc/sgi-xp/xpc.ko] undefined!
ERROR: "gru_create_message_queue" [drivers/misc/sgi-xp/xpc.ko] undefined!
ERROR: "gru_copy_gpa" [drivers/misc/sgi-xp/xp.ko] undefined!

So there is obviously something else needed.

-Tony
