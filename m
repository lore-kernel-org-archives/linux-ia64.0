From: Sam Ravnborg <sam@ravnborg.org>
Date: Mon, 16 Dec 2002 21:16:40 +0000
Subject: Re: [Linux-ia64] ia64 SN update
Message-Id: <marc-linux-ia64-105590709805573@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805522@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805522@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On man, dec 09, 2002 at 01:03:56 -0800, Jesse Barnes wrote:
> David, here's a patch to update SN support in the ia64 tree.

=== arch/ia64/sn/kernel/Makefile 1.7 vs edited ==--- 1.7/arch/ia64/sn/kernel/Makefile    Sun Sep 22 16:34:28 2002
+++ edited/arch/ia64/sn/kernel/Makefile Tue Dec  3 18:07:29 2002
XXX
+.S.s:
+       $(CPP) $(AFLAGS) $(AFLAGS_KERNEL) -o $*.s $<
+.S.o:
+       $(CC) $(AFLAGS) $(AFLAGS_KERNEL) -c -o $*.o $<

Do you really need this. kbuild contains the above rules, and if it
does not work deleting the above lines I would like to know.

Same comment for sn1 and sn2.

Also could you please delete inclusion of Rules.make, it has disappeared
from Linus's tree.

	Sam

