From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 27 Feb 2008 14:38:04 +0000
Subject: RE: Tiger oops in ia64_sal_physical_id_info (was [RFC] regression:113134fcbca83619be4c68d0ca66db6093
Message-Id: <1FE6DD409037234FAB833C420AA843ECACB7E1@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200802251027.15107.bjorn.helgaas@hp.com>
In-Reply-To: <200802251027.15107.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > Did it work before?
>
> Yes.

How about a more drastic approach to avoiding the
problem ... avoid any poking around looking for
siblings on pre-montecito processors?


diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index ebd1a09..7b0e396 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -736,7 +736,8 @@ identify_cpu (struct cpuinfo_ia64 *c)
 	c->threads_per_core = c->cores_per_socket = c->num_log = 1;
 	c->socket_id = -1;
 
-	identify_siblings(c);
+	if (cpuid.field.family > 0x1f)
+		identify_siblings(c);
 
 	if (c->threads_per_core > smp_num_siblings)
 		smp_num_siblings = c->threads_per_core;
