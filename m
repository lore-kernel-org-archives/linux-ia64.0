From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 09 Jun 2004 22:44:09 +0000
Subject: RE: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F016C46B1@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
In-Reply-To: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>That is in my opinion a worse patch compared to the reinitialization
>that you proposed esterday.  Tony, what's your take on this problem?

I think it would be better to fix up init_task so that it appeared
to be in region 7 (that way it isn't a special case ... it just looks
like every other task).  BUT, I'm not sure how easy that is to do
without surgery to generic files (places that use "&init_task").

-Tony
