From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 03 Apr 2012 18:11:03 +0000
Subject: RE: [PATCH] ia64: fix halt build fallout from deeper C state support.
Message-Id: <3908561D78D1C84285E8C5FCA982C28F170CB4CD@ORSMSX104.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1333469883-20509-1-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <1333469883-20509-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>[Tony - I dont know enough about ia64 to be sure this makes sense,
> so feel free to junk this patch and treat the mail as just a build
> failure regression report if there is a better fix.]

Paul,

It makes sense - but we are going with an alternate fix of
making the ACPI code use "safe_halt()" rather than just "halt()".
Thanks for taking the time to research and code up a fix though.

Hopefully Len will push that to Linus real-soon-now (hint, hint).

-Tony
