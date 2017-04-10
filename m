From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 10 Apr 2017 17:23:28 +0000
Subject: Re: [PATCH v3] ia64: fix module loading for gcc-5.4+
Message-Id: <d8146490-2bc4-3884-a64e-1e5894a023e3@users.sourceforge.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <to=<20170408081449.4872-1-slyfox@gentoo.org>
 <20170408195318.18080-1-slyfox@gentoo.org>
In-Reply-To: <20170408195318.18080-1-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyfox@gentoo.org>, linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Fenghua Yu <fenghua.yu@intel.com>, "H. J. Lu" <hjl.tools@gmail.com>, Tony Luck <tony.luck@intel.com>

> +++ b/arch/ia64/kernel/module.c
> @@ -153,7 +153,7 @@ slot (const struct insn *insn)
>  static int
>  apply_imm64 (struct module *mod, struct insn *insn, uint64_t val)
>  {

I have got another idea (after your clarification) for the suggested change.


> -	if (slot(insn) != 2) {
> +	if (slot(insn) != 1 && slot(insn) != 2) {

+	int const s = slot(insn);
+	if (s < 1 || s > 2) {

Do run time characteristics matter for such a condition check here?


>  		printk(KERN_ERR "%s: invalid slot number %d for IMM64\n",

-  		       mod->name, slot(insn));
+  		       mod->name, s);


>  		return 0;


How do you think about my update suggestion for this function implementation?

Regards,
Markus
