From: Kiran VMS <kiran.vms@gmail.com>
Date: Mon, 08 Nov 2004 09:13:09 +0000
Subject: IA-64 "instruction group" query...
Message-Id: <ff13ce6004110801011d668bbb@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Greetings,

I am just curious to know if the following instruction bundles are
valid ones. In particular, I would like to know if the instruction
group comprised of the slots # 1 ( 3621 ),  # 2 ( 3622 ) of the first
instruction bundle and slot # 0 ( 3630 ) is a VALID group. If you
notice, the register R4 is being read as well as modified by these
instructions belonging to the same group. Is it a potential RAW --
Read After Write -- violation?

(Assume that the traget processor is Itanium with its feature that it
can execute 2 bundles at a time)

                          { .mmi
010800458100     3620                 adds    r4 = 44, r4 ;;
008080400200     3621                 ld4     r8 = [r4]
010800400480     3622                 adds    r18 = 0, r4
                           }
                           { .mmi
0119F84A8100     3630                 adds    r4 = -44, r4 ;;
000008000000     3631                 nop.m   0              
0000B0800200     3632                 sxt4    r8 = r8 ;;
			   }


Instruction group of my concern 
;;
008080400200     3621                 ld4     r8 = [r4]
010800400480     3622                 adds    r18 = 0, r4
                           }
                           { .mmi
0119F84A8100     3630                 adds    r4 = -44, r4 
;;

Thanks for your time and attention
