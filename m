From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 17 Oct 2003 15:51:47 +0000
Subject: Re: [2.6 PATCH] Missing exported symbol
Message-Id: <marc-linux-ia64-106640598821231@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106638921002098@msgid-missing>
In-Reply-To: <marc-linux-ia64-106638921002098@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 17 Oct 2003 13:12:07 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> +EXPORT_SYMBOL(machine_power_off);
  Andreas> +EXPORT_SYMBOL(machine_restart);

These are supposed to be exported where they get defined (actually,
true for everything in ia64_ksyms.c).  I had a fix for this, but due
to operator-error it got lost.  I'll re-fix it.

	--david

