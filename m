From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 01 Aug 2008 23:24:04 +0000
Subject: Problem booting on some HP systems
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3082ABE01@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Recent kernels are not booting on some HP systems (though
it does boot on others).  James spent time and tracked it
to this patch in the pvops series:

commit 498c5170472ff0c03a29d22dbd33225a0be038f4
Author: Isaku Yamahata <yamahata@valinux.co.jp>
Date:   Mon May 19 22:13:38 2008 +0900

    [IA64] pvops: paravirtualize ivt.S

I did a quick compile with and without this patch applied and
compared the diassembled ivt.o file and spotted two places
where an _FROM_ macro had been used where _TO_ was intended.
See the <<<<< OOPS below:


@@ -1360,26 +1357,26 @@ ENTRY(speculation_vector)
         *
         * cr.imm contains zero_ext(imm21)
         */
-       mov r18=cr.iim
+       MOV_FROM_IIM(r18)
        ;;
-       mov r17=cr.iip
+       MOV_FROM_IIP(r17)
        shl r18=r18,43                  // put sign bit in position (43d-21)
        ;;

-       mov r16=cr.ipsr
+       MOV_FROM_IPSR(p0, r16)
        shr r18=r18,39                  // sign extend (39C-4)
        ;;

        add r17=r17,r18                 // now add the offset
        ;;
-       mov cr.iip=r17
+       MOV_FROM_IIP(r17) <<<<<<< OOPS!
        dep r16=0,r16,41,2              // clear EI
        ;;

-       mov cr.ipsr=r16
+       MOV_FROM_IPSR(p0, r16) <<<<<<<< OOPS!
        ;;

-       rfi                             // and go back
+       RFI
 END(speculation_vector)


I don't know whether these are the cause of the problems on James'
and Willy's machines (could you try swapping these round please?)

-Tony
