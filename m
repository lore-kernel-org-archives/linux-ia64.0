From: "Liu, Benjamin" <benjamin.liu@intel.com>
Date: Fri, 12 Mar 2004 09:25:03 +0000
Subject: RE: 2.6.3 compilation problem
Message-Id: <3ACA40606221794F80A5670F0AF15F8401B1A07D@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C40813.E66106FC"
List-Id: <linux-ia64.vger.kernel.org>
References: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
In-Reply-To: <002f01c40735$8d2cc880$39624c0f@india.hp.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C40813.E66106FC
Content-Type: text/plain;
	charset="GB2312"
Content-Transfer-Encoding: quoted-printable

The linker's error report is kind of misleading in this case, there is =
no discarded reference from serio_close/serio_init.

To workaround the problem, we can reserve "exit.text" into final vmlinux =
image, which will enlarge the image size a little bit. I've attached the =
patch.

Another way is to upgrade binutils package, newer linker will report =
warning instead of error for this case.

Thanks,
Pingping (Benjamin) Liu
Intel China Software Center


>-----Original Message-----
>From: linux-ia64-owner@vger.kernel.org=20
>[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Liu, Benjamin
>Sent: 2004=C4=EA3=D4=C211=C8=D5 16:33
>To: Sourav Sen; linux-ia64@vger.kernel.org
>Subject: RE: 2.6.3 compilation problem
>
>
>To workaround the problem, you can append=20
>__attribute__((weak)) to the declaration of those discarded=20
>symbols defined in section ".exit.text".
>
>Another workaround is to keep section ".exit.text" by=20
>modifying arch/ia64/vmlinux.lds.S.=20
>
>The device driver author might be able to answer why it is=20
>written that way.
>
>Thanks,
>Pingping (Benjamin) Liu
>Intel China Software Center
>
>
>>-----Original Message-----
>>From: linux-ia64-owner@vger.kernel.org=20
>>[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Sourav Sen
>>Sent: 2004=C4=EA3=D4=C211=C8=D5 14:53
>>To: linux-ia64@vger.kernel.org
>>Subject: 2.6.3 compilation problem
>>
>>
>>Hi,
>>
>>While compiling Linux 2.6.3 + ia64 patch for it, using
>>the following:
>>
>>[sourav]$ gcc --version
>>gcc (GCC) 3.1
>>[sourav]$ as --version
>>GNU assembler 2.13.90 20030125
>>[sourav]$ ld --version
>>GNU ld version 2.12.90 20020604
>>
>>I get the following error while doing
>>make vmlinux
>>
>>------
>>[...]
>> IKCFG   kernel/config_data.h
>>  CC      kernel/configs.o
>>  LD      kernel/built-in.o
>>  GEN     .version
>>  CHK     include/linux/compile.h
>>dnsdomainname: Host name lookup failure
>>  UPD     include/linux/compile.h
>>  CC      init/version.o
>>  LD      init/built-in.o
>>  LD      .tmp_vmlinux1
>>drivers/built-in.o: In function `serio_close':
>>drivers/built-in.o(.text+0x130c02): undefined reference to=20
>>`local symbols in
>>discarded section .exit.text'
>>drivers/built-in.o: In function `serio_init':
>>drivers/built-in.o(.init.text+0x10502): undefined reference to `local
>>symbols in discarded section .exit.text'
>>make: *** [.tmp_vmlinux1] Error 1
>>[...]
>>--------
>>
>>Any idea what I am doing wrong?
>>
>>TIA
>>--Sourav
>>
>>-
>>To unsubscribe from this list: send the line "unsubscribe=20
>>linux-ia64" in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>-
>To unsubscribe from this list: send the line "unsubscribe=20
>linux-ia64" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

------_=_NextPart_001_01C40813.E66106FC
Content-Type: application/octet-stream;
	name="text.exit.patch"
Content-Transfer-Encoding: base64
Content-Description: text.exit.patch
Content-Disposition: attachment;
	filename="text.exit.patch"

LS0tIGFyY2gvaWE2NC9rZXJuZWwvdm1saW51eC5sZHMuUy5vbGQJMjAwNC0wMy0xMiAxNTo0MToy
NC4wMDAwMDAwMDAgKzA4MDAKKysrIGFyY2gvaWE2NC9rZXJuZWwvdm1saW51eC5sZHMuUwkyMDA0
LTAzLTEyIDE1OjQxOjU4LjAwMDAwMDAwMCArMDgwMApAQCAtMTYsNyArMTYsNiBAQAogewogICAv
KiBTZWN0aW9ucyB0byBiZSBkaXNjYXJkZWQgKi8KICAgL0RJU0NBUkQvIDogewotCSooLmV4aXQu
dGV4dCkKIAkqKC5leGl0LmRhdGEpCiAJKiguZXhpdGNhbGwuZXhpdCkKIAkqKC5JQV82NC51bndp
bmQuZXhpdC50ZXh0KQpAQCAtMzYsNiArMzUsNyBAQAogCSooLnRleHQuaXZ0KQogCSooLnRleHQp
CiAJKiguZ251LmxpbmtvbmNlLnQqKQorCSooLmV4aXQudGV4dCkKICAgICB9CiAgIC50ZXh0MiA6
IEFUKEFERFIoLnRleHQyKSAtIExPQURfT0ZGU0VUKQogCXsgKigudGV4dDIpIH0K

------_=_NextPart_001_01C40813.E66106FC--
