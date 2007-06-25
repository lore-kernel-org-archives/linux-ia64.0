From: Robert Nagy <robert.nagy@gmail.com>
Date: Mon, 25 Jun 2007 22:13:49 +0000
Subject: intercept trap when running a 32bit binary
Message-Id: <20070625221349.GA25054@bsd.hu>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi

I am trying to run 32bit binary Half Life dedicated server from Valve.

This is what happens (in a 32bit chroot or with 32bit libs installed:

./srcds_run: line 344: 13869 Segmentation fault      (core dumped)            
$HL_CMD                                                 
Cannot access memory at address 0xbfffb91c                                                                                                                            
/root/srcds/debug.cmds:4: Error in sourced command file:                                                                                                              
Cannot access memory at address 0xbfffb91c                                                                                                                            

I either get:                                                                                                                                                                      
Unexpected IA-32 intercept trap (Trap 46)                      
  iip - 0x40c79b0b, ifa - 0x40f34000, isr - 0x11a6, iim - 0xc92a0f
Unexpected IA-32 intercept trap (Trap 46)                    
  iip - 0x40c79b0b, ifa - 0x40f34000, isr - 0x11a6, iim - 0xc92a0f
Unexpected IA-32 intercept trap (Trap 46)
  iip - 0x40c79b0b, ifa - 0x40f34000, isr - 0x11a6, iim - 0xc92a0f
Unexpected IA-32 intercept trap (Trap 46)
  iip - 0x40c79b0b, ifa - 0x40f34000, isr - 0x11a6, iim - 0xc92a0f
Unexpected IA-32 intercept trap (Trap 46)
  iip - 0x40c79b0b, ifa - 0x40f34000, isr - 0x11a6, iim - 0xc92a0f
Unexpected IA-32 intercept trap (Trap 46) 
  iip - 0x40c79b0b, ifa - 0x40f34000, isr - 0x11a6, iim - 0xc92a0f

or

Unexpected IA-32 intercept trap (Trap 46)
  iip - 0x401c683d, ifa - 0x4821b6af, isr - 0x600040000, iim - 0x0
Unexpected IA-32 intercept trap (Trap 46)
  iip - 0x401c683d, ifa - 0x4821b6af, isr - 0x600040000, iim - 0x0

The process gets a SIGSEGV there, from the kernel.

Is there anything i can do to make it work? Thanks

dmesg: http://www.pastebin.ca/589305
