From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 23 Jul 2004 20:11:35 +0000
Subject: Re: [PATCH] bug in irq_affinity_write_proc
Message-Id: <16641.28919.61298.662420@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40FE2EBE.4070007@jp.fujitsu.com>
In-Reply-To: <40FE2EBE.4070007@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 21 Jul 2004 17:52:14 +0900, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com> said:

  Kenji> Hi, Writing a value with 'R' or 'r' character to
  Kenji> /proc/irq/<IRQ#>/smp_affinity causes a kernel Oops. The
  Kenji> following patch fixes this issue.

  Kenji> Signed-off-by: Kenji Kaneshige
  Kenji> <kaneshige.kenji@jp.fujitsu.com>

How about using a bitset for pending_irq_redir?  Or at least a
byte-array instead of a word-array.

	--david
