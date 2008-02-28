From: Alex Chiang <achiang@hp.com>
Date: Thu, 28 Feb 2008 00:12:26 +0000
Subject: Re: Tiger oops in ia64_sal_physical_id_info (was [RFC]
Message-Id: <20080228001226.GB29968@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Alex Chiang <achiang@hp.com>:
> 
> And if anyone has other suggestions too, I'm happy to hear them.

Actually, this might be a relatively clean approach. As far as I
can tell, the only purpose for sal_revision / sal_version is to
display some boot messages. No one (other than my use below) is
keying off them for anything.

My fixup is based on the mail that Russ sent out with his
bootlog. It contained this line:

SAL 2.9: SGI SN2 version 1.30

So that's what I'm keying off of below.

Thanks.

/ac

From: Alex Chiang <achiang@hp.com>
Subject: [PATCH] ia64: workaround tiger ia64_sal_get_physical_id_info hang

Intel Tiger platforms hang when calling SAL_GET_PHYSICAL_ID_INFO
instead of properly returning -1 for unimplemented, so add a
version check.

SGI Altix platforms have an incorrect SAL version hard-coded into
their prom -- they encode 2.9, but actually implement 3.2 -- so
fix it up and allow ia64_sal_get_physical_id_info to keep
working.

Signed-off-by: Alex Chiang <achiang@hp.com>
---
diff --git a/arch/ia64/kernel/sal.c b/arch/ia64/kernel/sal.c
index f44fe84..4f3686a 100644
--- a/arch/ia64/kernel/sal.c
+++ b/arch/ia64/kernel/sal.c
@@ -109,6 +109,15 @@ check_versions (struct ia64_sal_systab *systab)
 		sal_revision = SAL_VERSION_CODE(2, 8);
 		sal_version = SAL_VERSION_CODE(0, 0);
 	}
+
+	if (ia64_platform_is("sn2")
+		&& (sal_revision = SAL_VERSION_CODE(2, 9))
+		&& (sal_version = SAL_VERSION_CODE(1, 90)))
+		/*
+		 * SGI Altix has hard-coded version 2.9 in their prom
+		 * but they actually implement 3.2, so let's fix it here.
+		 */
+		sal_revision = SAL_VERSION_CODE(3, 2);
 }
 
 static void __init
diff --git a/include/asm-ia64/sal.h b/include/asm-ia64/sal.h
index 2251118..f4904db 100644
--- a/include/asm-ia64/sal.h
+++ b/include/asm-ia64/sal.h
@@ -807,6 +807,10 @@ static inline s64
 ia64_sal_physical_id_info(u16 *splid)
 {
 	struct ia64_sal_retval isrv;
+
+	if (sal_revision < SAL_VERSION_CODE(3,2))
+		return -1;
+
 	SAL_CALL(isrv, SAL_PHYSICAL_ID_INFO, 0, 0, 0, 0, 0, 0, 0);
 	if (splid)
 		*splid = isrv.v0;
