From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 04 Aug 2003 21:53:17 +0000
Subject: RE: [PATCH] New CMC/CPE polling
Message-Id: <marc-linux-ia64-106003582921053@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105969308328993@msgid-missing>
In-Reply-To: <marc-linux-ia64-105969308328993@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>    With the modifications above, there is a tiny window where the
> other CPUs could take a CMCI while the cmc_polling_enabled flag is in
> the wrong state.  IMHO, this doesn't really seem like a problem.

Yup, you are right.

-Tony
