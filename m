From: Takuichi Hoshina <takuichi.hoshina@itg.hitachi.co.jp>
Date: Fri, 03 Aug 2001 10:44:27 +0000
Subject: [Linux-ia64] VGA Xwindow
Message-Id: <marc-linux-ia64-105590693005998@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

HI,

I have a IA64,Itanium(B3) machine. 
I have installed RedHat Linux Beta7.0.98(Wolverine). 
I updated kernel2.4.5 and patched ia64-010626.

Could somebody please give me advices about
 how to create XF86Config for VGA 4bit colors and 640*480?

I tried as below.
It does not work Xwindow on IA64, but it works on IA32.

-------------------------------------
# XFree86 4.0 configuration

  :

Section "Device"
    Identifier	"Generic VGA"
    Driver	"vga"
EndSection

Section "Screen"
    Identifier	"Screen0"
    Device	"Generic VGA"
    Monitor	"Generic Monitor"
    DefaultDepth 4
    SubSection "Display"
        Depth		4
        Modes		"640x480"
    EndSubSection
EndSection

------------------------------------------

Has anyone seen this or know what is causing the problem?

Thanks 

Taku

