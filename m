From: Matthew Wilcox <willy@debian.org>
Date: Mon, 23 Feb 2004 21:01:05 +0000
Subject: SAL version checking
Message-Id: <20040223210103.GG25779@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I need to check what version of SAL is available on the machine.
I didn't see a way to do this yet, so I'm writing one.  My first attempt
was simply:

#define SAL_CHECK_VERSION(tab, major, minor)                            \
        ((tab->sal_rev_major > major) ||                                \
         ((tab->sal_rev_major = major) && (tab->sal_rev_minor >= minor)))

which works except it requires callers to specify the version in hex
(and will work in 99% of cases if you don't ...) and requires the
caller to know that the SAL version is in sal_systab and sal_systab is
an EFI table.  This is clearly suboptimal.  Here's my current solution
(whitespace damaged :-P)

@@ -21,6 +21,8 @@
 spinlock_t sal_lock __cacheline_aligned = SPIN_LOCK_UNLOCKED;
 unsigned long sal_platform_features;
 
+static int sal_ver_major, sal_ver_minor;
+
 static struct {
        void *addr;     /* function entry point */
        void *gpval;    /* gp value to use */
@@ -103,11 +105,13 @@ ia64_sal_init (struct ia64_sal_systab *s
        if (strncmp(systab->signature, "SST_", 4) != 0)
                printk(KERN_ERR "bad signature in system table!");
 
-       /*
-        * revisions are coded in BCD, so %x does the job for us
-        */
-       printk(KERN_INFO "SAL v%x.%02x: oem=%.32s, product=%.32s\n",
-              systab->sal_rev_major, systab->sal_rev_minor,
+       sal_rev_major = (systab->sal_rev_major / 16) * 10 +
+                       systab->sal_rev_major % 16;
+       sal_rev_minor = (systab->sal_rev_minor / 16) * 10 +
+                       systab->sal_rev_minor % 16;
+
+       printk(KERN_INFO "SAL v%d.%d: oem=%.32s, product=%.32s\n",
+              sal_rev_major, sal_rev_minor,
               systab->oem_id, systab->product_id);
 
        min = ~0UL;
@@ -185,4 +189,13 @@ ia64_sal_init (struct ia64_sal_systab *s
                }
                p += SAL_DESC_SIZE(*p);
        }
+}
+
+int sal_check_version(int major, int minor)
+{
+       if (major < sal_rev_major)
+               return 1;
+       if (major > sal_rev_major)
+               return 0;
+       return (sal_rev_minor >= minor);
 }


Anyone want to propose a different solution?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
