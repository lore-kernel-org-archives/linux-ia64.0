From: Christian Groessler <cpg@aladdin.de>
Date: Thu, 27 Dec 2001 21:59:19 +0000
Subject: [Linux-ia64] kernel update (relative to v2.4.17)
Message-Id: <marc-linux-ia64-105590698805723@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I had to make the following change for it to compile on UP:

--- arch/ia64/kernel/setup.c.org        Thu Dec 27 22:39:49 2001
+++ arch/ia64/kernel/setup.c    Thu Dec 27 22:49:45 2001
@@ -488,7 +488,9 @@ identify_cpu (struct cpuinfo_ia64 *c)
                cpuid.bits[i] = ia64_get_cpuid(i);
 
        memcpy(c->vendor, cpuid.field.vendor, 16);
+#ifdef CONFIG_SMP
        c->processor = smp_processor_id();
+#endif
        c->ppn = cpuid.field.ppn;
        c->number = cpuid.field.number;
        c->revision = cpuid.field.revision;


regards,
chris


