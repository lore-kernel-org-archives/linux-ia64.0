From: Clay Cooper <clay_cooper@dell.com>
Date: Fri, 20 Oct 2000 22:28:52 +0000
Subject: [Linux-ia64] Aspen on Bordeaux
Message-Id: <marc-linux-ia64-105590678205603@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

  Here are the results of the Aspen in the individual Bordeaux slots:
I created a 4 disk Raid 5 container.
Slot 1 -- Kernel Panic
Slot 2 --  Attempt to insmod Megaraid module locks up machine.  At.....
                       "Found a MegaRaid controller at 0xf0000000, IRQ: 17"
Slot 3 --  Lock at insmod.....    0xec000000  IRQ: 18
Slot 4 --  Lock at insmod.....    0xe8000000  IRQ: 19
Slot 5 --  Kernel Panic
Slot 6 --  Lock at insmod.....    0xe4000000  IRQ: 21
Slot 7 --  Locked up at Aspen Bios before "logical drive found" after 
cold boot. 
                    Second cold boot went through Aspen Bios and kernel 
panicked
                    Then a warm boot which also kernel panicked.
Slot 8 --  After "EFI version strings" and after "FRU buffer size8"
                    Received a message stating:  "Didn't find Multi_record
                                                                        
      KCS Send Message failed.  rc=1
                                                                        
      Press any key"
                   Then....  a lock at insmod
                    0xe0000000  IRQ: 23
Slot 9 --  Kernel Panic
Slot 10 -- Lock at insmod
                      0xd8000000  IRQ: 25

-- 
Clay Cooper
Engineering Tech/Sr. Analyst
Clay_Cooper@Dell.com
512.723.5951


