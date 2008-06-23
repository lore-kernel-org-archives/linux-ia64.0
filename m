From: Cliff Wickman <cpw@sgi.com>
Date: Mon, 23 Jun 2008 13:39:58 +0000
Subject: [PATCHv3] SN2: security hole in sn2_ptc_proc_write
Message-Id: <E1KAmH0-0002Ii-Gq@eag09.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



From: Cliff Wickman <cpw@sgi.com>

Security hole in sn2_ptc_proc_write

It is possible to overrun a buffer with a write to this /proc file.

v2: An improvement suggested by Russ Anderson:
  > +     if (count > 64)
  > +     if (count > sizeof(optstr))

v3: Andi Kleen noticed a problem if the user writes 0 bytes
    (it can't be <0 because count is unsigned)

Diffed against 2.6.26-rc5

Signed-off-by: Cliff Wickman <cpw@sgi.com>
---
 arch/ia64/sn/kernel/sn2/sn2_smp.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6/arch/ia64/sn/kernel/sn2/sn2_smp.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ linux-2.6/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -512,6 +512,8 @@ static ssize_t sn2_ptc_proc_write(struct
 	int cpu;
 	char optstr[64];
 
+	if (count = 0 || count > sizeof(optstr))
+		return -EINVAL;
 	if (copy_from_user(optstr, user, count))
 		return -EFAULT;
 	optstr[count - 1] = '\0';
