From: Jes Sorensen <jes@wildopensource.com>
Date: Tue, 27 Jan 2004 08:11:03 +0000
Subject: Re: [patch] 2.6.1-mm5 compile do not use shared extable code for ia64
Message-Id: <yq0y8rtreug.fsf@wildopensource.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <E1Aiuv7-0001cS-00@jaguar.mkp.net>
	<20040120090004.48995f2a.akpm@osdl.org>
	<16401.57298.175645.749468@napali.hpl.hp.com>
	<16402.19894.686335.695215@cargo.ozlabs.ibm.com>
	<16405.41953.344071.456754@napali.hpl.hp.com>
In-Reply-To: <16405.41953.344071.456754@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

David,

I am just nitpicking here, but wouldn't it be better to stick to the
convention of all upper case defines for the #ifdef check?

Maybe use something like?
#define ARCH_EXTABLE_COMPARE_ENTRIES ia64_extable_compare_entries

Cheers,
Jes


@@ -18,7 +18,25 @@
 extern struct exception_table_entry __start___ex_table[];
 extern struct exception_table_entry __stop___ex_table[];
 
-#ifndef ARCH_HAS_SORT_EXTABLE
+#ifndef extable_compare_entries
+
+/*
+ * Compare exception-table entries L and R and return <0 if L is smaller, 0 if L and R are
+ * equal and >0 if L is bigger.
+ */
