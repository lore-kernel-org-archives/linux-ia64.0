From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 10 Apr 2002 22:23:47 +0000
Subject: Re: [Linux-ia64] new kernel patch (relative to 2.4.18)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="SUOF0GtieIMvvwua"
Message-Id: <marc-linux-ia64-105590701905428@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905293@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905293@msgid-missing>
To: linux-ia64@vger.kernel.org

--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

To All,

You need this extra perfmon patch to get the Itanium working. I gave
David the wrong version of perfmon_itanium.h. Apply the attached  
small patch on top of David's linux-2.4.18-ia64-020410.diff.gz patch.

Sorry for the inconvience.

--
-Stephane

--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=perfmon-020410

--- /nue/usr/src/sys/lia64-2.4/arch/ia64/kernel/perfmon_itanium.h	Wed Apr 10 11:16:59 2002
+++ build.2417mck/arch/ia64/kernel/perfmon_itanium.h			Wed Apr 10 15:15:23 2002
@@ -11,15 +11,15 @@
 /* pmc1  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc2  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc3  */ { PFM_REG_CONTROL, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
-/* pmc4  */ { PFM_REG_COUNTING, 0, NULL, NULL, {RDEP(4),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
-/* pmc5  */ { PFM_REG_COUNTING, 0, NULL, NULL, {RDEP(5),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
-/* pmc6  */ { PFM_REG_COUNTING, 0, NULL, NULL, {RDEP(6),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
-/* pmc7  */ { PFM_REG_COUNTING, 0, NULL, NULL, {RDEP(7),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc4  */ { PFM_REG_COUNTING, 6, NULL, NULL, {RDEP(4),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc5  */ { PFM_REG_COUNTING, 6, NULL, NULL, {RDEP(5),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc6  */ { PFM_REG_COUNTING, 6, NULL, NULL, {RDEP(6),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc7  */ { PFM_REG_COUNTING, 6, NULL, NULL, {RDEP(7),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc8  */ { PFM_REG_CONFIG, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc9  */ { PFM_REG_CONFIG, 0, NULL, NULL, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
-/* pmc10 */ { PFM_REG_MONITOR, 0, NULL, NULL, {RDEP(0)|RDEP(1),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
-/* pmc11 */ { PFM_REG_MONITOR, 0, NULL, pfm_ita_pmc_check, {RDEP(2)|RDEP(3)|RDEP(17),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
-/* pmc12 */ { PFM_REG_MONITOR, 0, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDEP(11)|RDEP(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc10 */ { PFM_REG_MONITOR, 6, NULL, NULL, {RDEP(0)|RDEP(1),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc11 */ { PFM_REG_MONITOR, 6, NULL, pfm_ita_pmc_check, {RDEP(2)|RDEP(3)|RDEP(17),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
+/* pmc12 */ { PFM_REG_MONITOR, 6, NULL, NULL, {RDEP(8)|RDEP(9)|RDEP(10)|RDEP(11)|RDEP(12)|RDEP(13)|RDEP(14)|RDEP(15)|RDEP(16),0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
 /* pmc13 */ { PFM_REG_CONFIG, 0, NULL, pfm_ita_pmc_check, {0UL,0UL, 0UL, 0UL}, {0UL,0UL, 0UL, 0UL}},
 	    { PFM_REG_NONE, 0, NULL, NULL, {0,}, {0,}}, /* end marker */
 };

--SUOF0GtieIMvvwua--

