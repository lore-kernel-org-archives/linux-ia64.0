From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 28 May 2003 20:13:21 +0000
Subject: RE: [Linux-ia64] RE: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723706057@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Aaargh!  Still not right.  That includes a spurious
hunk that backout out part of the FP fix.  Don't apply
this bit!

@@ -779,8 +787,6 @@
 	/* Clear the stack memory reserved for pt_regs: */
 	memset(ia64_task_regs(current), 0, sizeof(struct pt_regs));
 
-	ia64_set_kr(IA64_KR_FPU_OWNER, 0);
-
 	/*
 	 * Initialize default control register to defer all speculative faults.  The
 	 * kernel MUST NOT depend on a particular setting of these bits (in other words,



-Tony

