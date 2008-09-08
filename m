From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 08 Sep 2008 17:39:14 +0000
Subject: RE: [PATCH]Export the symbol ia64_patch_imm64.
Message-Id: <57C9024A16AD2D4C97DC78E552063EA30A147090@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC01923FC8@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDC01923FC8@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Why does this need to be exported?  I'm assuming
that kvm is involved ... but you should provide
some details in the patch so that the GIT commit
will have some descriptive value.

Is it a legacy case?  If not, then we should use
EXPORT_SYMBOL_GPL.

-Tony
