From: "Jon R. Doyle" <marsaro@interearth.com>
Date: Thu, 31 Oct 2002 16:22:34 +0000
Subject: Re: [Linux-ia64] USB Mouse on SLES8 Beta1
Message-Id: <marc-linux-ia64-105590709805314@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805291@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805291@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

----- Original Message -----
From: "Andreas Schwab" <schwab@suse.de>
To: "Jon R. Doyle" <jrd@sendmail.com>
Cc: <linux-ia64@linuxia64.org>
Sent: Thursday, October 31, 2002 4:31 AM
Subject: Re: [Linux-ia64] USB Mouse on SLES8 Beta1


> "Jon R. Doyle" <marsaro@interearth.com> writes:
>
> |> This seems to be broke:
> |>
> |> In Preview 5 & 6 of UL my Intel 4 CPU 900mhz SDV detects the keyboar
and
> |> mouse fine. SLES 8 beta 1 will not find the USB mouse

root@ia64-2.dev-lab.sendmail.com's password:
Last login: Wed Oct 30 13:42:42 2002 from shell.sendmail.com
ia64-2:~ # w
  9:23am  up 1 day, 20:48,  1 user,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU  WHAT
root     pts/0    shell.sendmail.c  9:23am  0.00s  0.04s  0.00s  w
ia64-2:~ # hwinfo --usb
03: USB 101.0: 10a00 Hub
  [Created at usb.100]
  Unique ID: B3Fu.Jt1hg9mdkyE
  Hardware Class: hub
  Model: "Hub"
  Hotplug: USB
  USB GUID: 000000000000000000000000
  USB Device status: driver active ("hub")
  Speed: 1.5 Mbps
  Config Status: cfg=3Dnew, avail=3Dyes, need=3Dno

04: USB 102.0: 10800 Keyboard
  [Created at usb.100]
  Unique ID: B3Fu.PWDW3qm03V3
  Hardware Class: keyboard
  Model: "SOLIDTEK USB Composite Keyboard"
  Hotplug: USB
  Vendor: usb 0x060b "Solid Year (?)"
  Device: usb 0x2001
  SubVendor:  "SOLIDTEK"
  SubDevice:  "USB Composite Keyboard"
  Revision: "1.00"
  USB GUID: 060b20010000000000000000
  USB Device status: driver active ("hid")
  Speed: 12 Mbps
  Driver Info #0:
    XkbRules: xfree86
  Config Status: cfg=3Dyes, avail=3Dyes, need=3Dyes
  Attached to: #3 (Hub)

05: USB 201.0: 10a00 Hub
  [Created at usb.100]
  Unique ID: 3Okj.Jt1hg9mdkyE
  Hardware Class: hub
  Model: "Hub"
  Hotplug: USB
  USB GUID: 000000000000000000000000
  USB Device status: driver active ("hub")
  Speed: 1.5 Mbps
  Config Status: cfg=3Dnew, avail=3Dyes, need=3Dno
ia64-2:~ #


> What kind of mouse do you have?  Please provide the output of
"hwinfo --usb".
>
> |> and therefore cause
> |> instal pains (read it is a pain to TAB key through Yast to complete
> |> install).
>
> Why don't you use the keyboard shortcuts?  Just press Alt + underlined
> character.

I will look at that, better would be "why not have Yast1 like interface for
SLES, since it is a server OS. Clearly Yast2 is designed for the desktop
users, where you will use KDE.



Regards,

Jon

>
> Andreas.
>
> --
> Andreas Schwab, SuSE Labs, schwab@suse.de
> SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
> Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
> "And now for something completely different."
>
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
>


