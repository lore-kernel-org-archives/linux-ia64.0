From: Mario Smarduch <cms063@email.mot.com>
Date: Fri, 26 Sep 2003 14:43:55 +0000
Subject: vhpt_miss handler question?
Message-Id: <marc-linux-ia64-106458752027199@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some work I'm doing has taken me to the vhpt_miss
handler. I've been looking at  the following snippet just
wondering what happens in the case where the present
bit is 0 and p10,p11 predicates are not set anotherwords
they retain their application values. Would this not
cause an errant insertion if either p10 or p11 were
true in the application prior to the VHPT handler?

- Mario.


(p7)    tbit.z p6,p7=r18,_PAGE_P_BIT            // page present bit
cleared?
        mov r22=cr.iha                          // get the VHPT address
that cau
sed the TLB miss
        ;;                                      // avoid RAW on p7
(p7)    tbit.nz.unc p10,p11=r19,32              // is it an instruction
TLB miss
?
        dep r23=0,r20,0,PAGE_SHIFT              // clear low bits to get
page ad
dress
        ;;
(p10)   itc.i r18                               // insert the
instruction TLB en
try
(p11)   itc.d r18                               // insert the data TLB
entry


