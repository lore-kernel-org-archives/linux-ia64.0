From: "Cook, Steven C" <steven.c.cook@intel.com>
Date: Thu, 18 Jan 2001 18:24:35 +0000
Subject: RE: [Linux-ia64] CD recorder software for Big Sur
Message-Id: <marc-linux-ia64-105590693005082@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005081@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005081@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Eric,

EFI shell only recognizes El Torito format CDs.  If you created the image in
ISO-9660, it will be unreadable in EFI Shell.  I believe EZ CD Creator is
capable of creating an El Torito CD, but I've not done it, so am unable to
provide more info.  Hope this helps.

--steve cook--
--steven.c.cook@intel.com--
--Workstation Product Division, Validation Engineering--

-----Original Message-----
From: Eric Wang [mailto:ericwang25@hotmail.com]
Sent: Thursday, January 18, 2001 10:18
To: linux-ia64@linuxia64.org
Subject: [Linux-ia64] CD recorder software for Big Sur


Dear all,

I have tried to use a PC and Easy Creator to create a iso image then burn 
into a CD, but I could not read this CD with Big Sur machine in EFI prompt. 
Would you please tell me where can I get a program that can burn a CD and be

read by Big Sur in EFI?

Thank you and have a nice day!

Eric

Eric Wang
IA64 desktop engineering
SGI

_________________________________________________________________________
Get Your Private, Free E-mail from MSN Hotmail at http://www.hotmail.com.


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


