From: "Govezensky, Yosi" <yosi.govezensky@intel.com>
Date: Tue, 05 Dec 2000 23:51:26 +0000
Subject: RE: [Linux-ia64] Information about EFI.
Message-Id: <marc-linux-ia64-105590678205794@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205775@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205775@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Sapariya,

The IA-32 development environment that David is referring to is part of the
sample implementation. You can download from the EFI web site:
http://developer.intel.com/technology/efi/

Yosi

-----Original Message-----
From: David Mosberger [mailto:davidm@hpl.hp.com]
Sent: Tuesday, December 05, 2000 11:17 PM
To: Sapariya Manish.j
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] Information about EFI.


>>>>> On Tue, 28 Nov 2000 14:42:42 +0530, "Sapariya Manish.j"
<S.Manish@zensar.com> said:

  Sapariya> Hi all, I dont know whethere this is the correct place to
  Sapariya> ask this question or not but i couldnt get it anywhere
  Sapariya> else.

  Sapariya> The question is about EFI bios32/ia64 emulator for 32 bit
  Sapariya> systems.

  Sapariya> I want to write a exception handler for my application
  Sapariya> written in EFI.  Right now i dont have access to 64 bit
  Sapariya> machine thats why i am trying it on 32 bit machine.

  Sapariya> But i could nt get any information about how could i do
  Sapariya> it.

  Sapariya> Any suggestions will be of great help.

Intel has (had?) an EFI implementation for IA-32 machines.  You put
that on a floppy disk, boot the system with it, and you get an EFI
prompt (nshell prompt, to be exact).  From there you can launch your
own EFI programs.  The GNU EFI support has support for building IA-32
EFI applications, but it hasn't been tested in a while (not since I
got IA-64 hw to play with, to be exact).  However, provided you have a
toolchain that builds valid IA-64 EFI applications, I think it's very
likely that the IA-32 side will also work, so it may be worth a try.

Hope this helps,

	--david

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


