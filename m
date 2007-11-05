From: Roel Kluin <12o3l@tiscali.nl>
Date: Mon, 05 Nov 2007 09:01:59 +0000
Subject: Re: [PATCH] Also iounmap in error path in arch/ia64/kernel/cyclone.c
Message-Id: <472EDC07.60801@tiscali.nl>
List-Id: <linux-ia64.vger.kernel.org>
References: <472D00A7.1080409@tiscali.nl>
In-Reply-To: <472D00A7.1080409@tiscali.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Simon Horman wrote:
> On Sun, Nov 04, 2007 at 12:13:43AM +0100, Roel Kluin wrote:
>> base is a local u64. use_cyclone a global int.
>> --
>> Also iounmap in error path
> 
> This seems correct, but doesn't the same problem occur several other
> times further down the same function?
> 

Ok, since the function was ioremap_nocache instead of ioremap, I wasn't sure
whether the unmap was required. Apparently I overlooked this was true for the
first case as well.

Thanks for reviewing.

--
iounmap after ioremap when CBAR/PMCC/MPCS/MPMC is not found

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/arch/ia64/kernel/cyclone.c b/arch/ia64/kernel/cyclone.c
index 790ef0d..64d3ab9 100644
--- a/arch/ia64/kernel/cyclone.c
+++ b/arch/ia64/kernel/cyclone.c
@@ -59,13 +59,13 @@ int __init init_cyclone_clock(void)
 		return -ENODEV;
 	}
 	base = readq(reg);
+	iounmap(reg);
 	if(!base){
 		printk(KERN_ERR "Summit chipset: Could not find valid CBAR"
 				" value.\n");
 		use_cyclone = 0;
 		return -ENODEV;
 	}
-	iounmap(reg);
 
 	/* setup PMCC */
 	offset = (base + CYCLONE_PMCC_OFFSET);
@@ -74,6 +74,7 @@ int __init init_cyclone_clock(void)
 		printk(KERN_ERR "Summit chipset: Could not find valid PMCC"
 				" register.\n");
 		use_cyclone = 0;
+		iounmap(reg);
 		return -ENODEV;
 	}
 	writel(0x00000001,reg);
@@ -86,6 +87,7 @@ int __init init_cyclone_clock(void)
 		printk(KERN_ERR "Summit chipset: Could not find valid MPCS"
 				" register.\n");
 		use_cyclone = 0;
+		iounmap(reg);
 		return -ENODEV;
 	}
 	writel(0x00000001,reg);
@@ -98,6 +100,7 @@ int __init init_cyclone_clock(void)
 		printk(KERN_ERR "Summit chipset: Could not find valid MPMC"
 				" register.\n");
 		use_cyclone = 0;
+		iounmap(cyclone_timer);
 		return -ENODEV;
 	}
 
