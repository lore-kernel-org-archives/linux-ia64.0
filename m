From: Steven Cole <scole@lanl.gov>
Date: Tue, 01 May 2001 19:08:09 +0000
Subject: [Linux-ia64] Request for Configure.help texts for IA64 options.
Message-Id: <marc-linux-ia64-105590693005502@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Greetings all,

Eric S. Raymond and I have recently become the maintainers of
the Configure.help file.  Here is a list of five IA64 config options which
are setable, but do not have Configure.help entries.

CONFIG_IA64_DEBUG_CMPXCHG
CONFIG_IA64_DEBUG_IRQ
CONFIG_IA64_EARLY_PRINTK
CONFIG_IA64_EFIVARS
CONFIG_IA64_PRINT_HAZARDS

Would someone please generate the help texts for these items, and send
the texts to Eric Raymond <esr@thyrsus.com> and cc to
Steven Cole <elenstev@mesatop.com>.

We are trying to produce a superset Configure.help file for Linus' and Alan's
tree's, so sending these texts directly to Alan or Linus right now might just 
confuse things.

Thanks in advance,

Steven

