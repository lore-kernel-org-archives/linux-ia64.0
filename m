From: "Moore, Robert" <robert.moore@intel.com>
Date: Tue, 04 Apr 2006 22:57:26 +0000
Subject: RE: 2.6.16 not booting due to ACPI  revision 20060127
Message-Id: <971FCB6690CD0E4898387DBF7552B90E04E7C019@orsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <44310983.3070000@bull.net>
In-Reply-To: <44310983.3070000@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: xb <xavier.bru@bull.net>, "Brown, Len" <len.brown@intel.com>, "Luck, Tony" <tony.luck@intel.com>, linux-acpi@vger.kernel.org, "Therien, Guy" <guy.therien@intel.com>
Cc: linux-ia64@vger.kernel.org


I believe that we must run _STA in order to determine whether the device is=
 present or not and whether to continue initialization of the device childr=
en.

Thus, the patch given is essentially correct.




-----Original Message-----
From: xb [mailto:xavier.bru@bull.net]=20
Sent: Tuesday, April 04, 2006 1:24 AM
To: Brown, Len; Moore, Robert; Luck, Tony; linux-acpi@vger.kernel.org; Ther=
ien, Guy
Cc: linux-ia64@vger.kernel.org
Subject: Re: 2.6.16 not booting due to ACPI revision 20060127

Hi Robert and len,

Thanks for answering my mail.
I think that the problem is that we execute methods on the hot plug control=
er for an unexisting bus.=20
There is a method that loops on a particular field:

000065f3:=A0 04 -------- Method WSOB
000065f9:=A0 05 . . . . .=A0 0x00
000065fa:=A0 05 . . . . .=A0 While
000065fc:=A0 06 . . . . . .=A0 SOBO
00006600:=A0 06 . . . . . .=A0 Noop

I put, attached a partial trace of the called methods, and a dump of the DS=
DT.
Thanks again.

Brown, Len wrote:=20
We have platforms that do not boot in 2.6.16, but boot OK with 2.6.15=20
(loop in ACPI code).
   =20

Sounds like it wouldn't have booted any of the 2.6.16 pre-release
candidates either...

 =20
Yes.

After some investigations, I found this is due to pci buses that are=20
described in the configuration, but not available in limited=20
configurations.
   =20

 =20
These buses have a _STA method, but no _INI method.
With 2.6.15, the _STA method is run, and as the bus is not=20
present, the bus and all devices behind it are ignored.
   =20

The non-present busses should still be ignored in 2.6.16,
independent of the STA/INI optimization.

 =20
How can this be done if we do not run the STA method ?

With 2.6.16, as no _INI method is provided for the bus, _STA method is=20
not run, and then we loop when executing methods for devices=20
behind the not present bus.
   =20

Need to find out what methods are looping on non-existent
devices, and why STA didn't prevent that.  This is probably
independent of the STA/INI optimization in 20060127.

 =20
As described earlier, we loop in WSOB method for hotplug controler for unex=
isting bus...

It sounds like either
1. we're not evaluating _STA someplace in the bus enumeration code
   when we should be, and perhaps this was masked in 2.6.15 when
   we blindly evaluated STA everywhere.

   I'll venture that is the issue here -- the STA/INI optimization
   has unmasked a Linux bug.  Note that the patch to
   again blindly execute STA everwhere would simply re-mask the bug,
   rather than fixing it directly.
or

2. _STA on this box is somehow special and has side effects.

 =20

Please open a bugzilla here:
http://bugzilla.kernel.org/enter_bug.cgi?product=ACPI

and attach the output from acpidump
acpidump is available in the latest pmtools here:
http://ftp.kernel.org/pub/linux/kernel/people/lenb/acpi/utils/


 =20
OK, I will do that.

Having a look to ACPI specification, I could find nowhere the=20
restriction that _STA method is called only when an _INI method is=20
provided for the device:

"6.5.1 _INI (Init)
...
If the _STA method indicates that the device is present, OSPM will=20
evaluate the _INI for the device (if the _INI method exists) and will=20
examine each of the children of the device for _INI methods.=20
If the _STA=20
method indicates that the device is not present, OSPM will not run the=20
_INI and will not examine the children of the device for _INI=20
methods. "
   =20

That is true, but it is also true that the ACPI spec doesn't say
how how many times STA will be evaluated, if at all.

 =20
traces -----------------------------------------------


Device PC11
000060e4:  02 . .  Name _HID
000060e9:  03 . . .  PNP0A03  PCI Bus  0x030ad041
000060ee:  02 . .  Name _UID
000060f3:  03 . . .  0x0b
000060f5:  02 . .  Name _ADR
000060fa:  03 . . .  0x00
000060fc:  02 ---- 'PCI bus number setup by the BIOS'  Method _BBN
00006102:  03 . . .  0x00
00006103:  03 . . .  Return
00006104:  04 . . . .  path: \_SB_.CSFF.IO15.B1__
00006117:  02 ---- 'Dynamic_Statu'  Method _STA
0000611d:  03 . . .  0x00
0000611e:  03 . . .  If
00006120:  04 . . . .  LEqual
00006121:  05 . . . . .  path: \_SB_.CSFF.IO11.HUBD
00006134:  05 . . . . .  0x00
00006136:  04 . . . .  Return
00006137:  05 . . . . .  0x0f
00006139:  03 . . .  Return
0000613a:  04 . . . .  0x00
0000613c:  02 ---- 'Current Resource Setting'  Method _CRS
00006142:  03 . . .  0x00
00006143:  03 . . .  Return
00006144:  04 . . . .  path: \_SB_.HLRS
0000614e:  03 . . .  0x01
00006150:  03 . . .  0x01
00006152:  02

   =20

Does this trace show the access to the bus that does not exist?
Where is the loop?
 =20
Yes (see traces).


thanks,
-Len

 =20
Moore, Robert wrote:=20
We changed the device initialization sequence to improve boot
performance by not executing _STA unless an _INI is actually present.

The change to selectively run _STA was made in 20051216, from the
release notes:

"Implemented an optimization to the initialization sequence that can
improve boot time. During ACPI device initialization, the _STA method is
now run if and only if the _INI method exists. The _STA method is used
to determine if the device is present; An _INI can only be run if _STA
returns present, but it is a waste of time to run the _STA method if the
_INI does not exist."

 =20
Our BIOS provides description for the maximum configuration, then I think i=
t relies on the fact we run _STA method on the bus before accessing devices=
 on that bus...


It is my understanding of the ACPI spec that there is no requirement
that _STA be run, ever. There is only a requirement that _INI be run if
the device is present and _INI exists.
=20
Therefore, the optimization above was implemented because we were only
running _STA to determine whether or not to run _INI. If there is no
_INI present, it is pointless to run the _STA.


 =20
Having a look to ACPI specification, I could find nowhere the=20
restriction that _STA method is called only when an _INI method is=20
provided for the device:

     =20

Yes, there is no restriction on when or if _STA can be run. However, I
do not think that there a *requirement* to run _STA, only _INI.

I don't understand why running _STA fixes the problem. Exactly what or
who is depending on _STA to be run?

Bob
 =20
