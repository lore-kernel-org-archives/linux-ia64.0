From: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Date: Fri, 24 Jan 2003 20:05:35 +0000
Subject: RE: [Linux-ia64] [Patch] trivial fix in linker script
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_001_01C2C3E3.F51450CB"
Message-Id: <marc-linux-ia64-105590709805748@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805734@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805734@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C2C3E3.F51450CB
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

hi David,

I agree. Attached a bigger patch now :)

thanks,
suresh

--- linux-2.5.52/arch/ia64/vmlinux.lds.S~	Fri Jan 17 17:58:44 2003
+++ linux-2.5.52/arch/ia64/vmlinux.lds.S	Fri Jan 24 11:08:06 2003
@@ -45,25 +45,29 @@
   _data =3D .;
=20
   /* Exception table */
-  . =3D ALIGN(16);
-  __start___ex_table =3D .;
   __ex_table : AT(ADDR(__ex_table) - PAGE_OFFSET)
-	{ *(__ex_table) }
-  __stop___ex_table =3D .;
+	{=20
+	   __start___ex_table =3D .;
+	   *(__ex_table)=20
+	   __stop___ex_table =3D .;
+	}
=20
 #if defined(CONFIG_IA64_GENERIC)
   /* Machine Vector */
-  . =3D ALIGN(16);
-  machvec_start =3D .;
   .machvec : AT(ADDR(.machvec) - PAGE_OFFSET)
-	{ *(.machvec) }
-  machvec_end =3D .;
+	{=20
+  	   machvec_start =3D .;
+	   *(.machvec)
+	   machvec_end =3D .;
+	}
 #endif
=20
-  __start___ksymtab =3D .;	/* Kernel symbol table */
   __ksymtab : AT(ADDR(__ksymtab) - PAGE_OFFSET)
-	{ *(__ksymtab) }
-  __stop___ksymtab =3D .;
+	{=20
+  	   __start___ksymtab =3D .;	/* Kernel symbol table */
+	   *(__ksymtab)=20
+  	   __stop___ksymtab =3D .;
+	}
=20
   __kallsyms : AT(ADDR(__kallsyms) - PAGE_OFFSET)
 	{
@@ -73,13 +77,14 @@
 	}
=20
   /* Unwind info & table: */
-  . =3D ALIGN(8);
   .IA_64.unwind_info : AT(ADDR(.IA_64.unwind_info) - PAGE_OFFSET)
 	{ *(.IA_64.unwind_info*) }
-  ia64_unw_start =3D .;
   .IA_64.unwind : AT(ADDR(.IA_64.unwind) - PAGE_OFFSET)
-	{ *(.IA_64.unwind*) }
-  ia64_unw_end =3D .;
+	{=20
+	   ia64_unw_start =3D .;
+	   *(.IA_64.unwind*)
+	   ia64_unw_end =3D .;
+	}
=20
   .rodata : AT(ADDR(.rodata) - PAGE_OFFSET)
 	{ *(.rodata) *(.rodata.*) }
@@ -98,23 +103,28 @@
   .init.data : AT(ADDR(.init.data) - PAGE_OFFSET)
 	{ *(.init.data) }
=20
-  __initramfs_start =3D .;
   .init.ramfs : AT(ADDR(.init.ramfs) - PAGE_OFFSET)
-	{ *(.init.ramfs) }
-  __initramfs_end =3D .;
+	{=20
+  	   __initramfs_start =3D .;
+	   *(.init.ramfs)
+	   __initramfs_end =3D .;
+	}
=20
-   . =3D ALIGN(16);
-  __setup_start =3D .;
   .init.setup : AT(ADDR(.init.setup) - PAGE_OFFSET)
-        { *(.init.setup) }
-  __setup_end =3D .;
-  __start___param =3D .;
+	{=20
+	   __setup_start =3D .;
+	   *(.init.setup)
+	   __setup_end =3D .;
+	}
   __param : AT(ADDR(__param) - PAGE_OFFSET)
-        { *(__param) }
-  __stop___param =3D .;
-  __initcall_start =3D .;
+	{=20
+	   __start___param =3D .;
+	   *(__param)
+	   __stop___param =3D .;
+	}
   .initcall.init : AT(ADDR(.initcall.init) - PAGE_OFFSET)
 	{
+		__initcall_start =3D .;
 		*(.initcall1.init)
 		*(.initcall2.init)
 		*(.initcall3.init)
@@ -122,8 +132,8 @@
 		*(.initcall5.init)
 		*(.initcall6.init)
 		*(.initcall7.init)
+		__initcall_end =3D .;
 	}
-  __initcall_end =3D .;
   . =3D ALIGN(PAGE_SIZE);
   __init_end =3D .;
=20
@@ -138,7 +148,6 @@
 	  __stop_gate_section =3D .;
 	}
=20
-  . =3D ALIGN(SMP_CACHE_BYTES);
   .data.cacheline_aligned : AT(ADDR(.data.cacheline_aligned) - =
PAGE_OFFSET)
         { *(.data.cacheline_aligned) }
=20

> -----Original Message-----
> From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
> Sent: Friday, January 24, 2003 10:30 AM
> To: Siddha, Suresh B
> Cc: davidm@hpl.hp.com; linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] [Patch] trivial fix in linker script
>=20
>=20
> >>>>> On Mon, 20 Jan 2003 19:16:09 -0800, "Siddha, Suresh B"=20
> <suresh.b.siddha@intel.com> said:
>=20
>   Suresh> There is a chance that __start___ksymtab may not point at
>   Suresh> the beginning of section __ksymtab. Appended/attached one
>   Suresh> line patch fixes this problem.
>=20
> It seems to me that a better solution would be to move
> __start___ksymtab inside the __ksymtab section.  That should make it
> always work, independent of what the real alignment of that section
> is.
>=20
> 	--david
>=20

------_=_NextPart_001_01C2C3E3.F51450CB
Content-Type: application/octet-stream;
	name="vmlinux.lds.S.diff"
Content-Transfer-Encoding: base64
Content-Description: vmlinux.lds.S.diff
Content-Disposition: attachment;
	filename="vmlinux.lds.S.diff"

LS0tIGxpbnV4LTIuNS41Mi9hcmNoL2lhNjQvdm1saW51eC5sZHMuU34JRnJpIEphbiAxNyAxNzo1
ODo0NCAyMDAzDQorKysgbGludXgtMi41LjUyL2FyY2gvaWE2NC92bWxpbnV4Lmxkcy5TCUZyaSBK
YW4gMjQgMTE6MDg6MDYgMjAwMw0KQEAgLTQ1LDI1ICs0NSwyOSBAQA0KICAgX2RhdGEgPSAuOw0K
IA0KICAgLyogRXhjZXB0aW9uIHRhYmxlICovDQotICAuID0gQUxJR04oMTYpOw0KLSAgX19zdGFy
dF9fX2V4X3RhYmxlID0gLjsNCiAgIF9fZXhfdGFibGUgOiBBVChBRERSKF9fZXhfdGFibGUpIC0g
UEFHRV9PRkZTRVQpDQotCXsgKihfX2V4X3RhYmxlKSB9DQotICBfX3N0b3BfX19leF90YWJsZSA9
IC47DQorCXsgDQorCSAgIF9fc3RhcnRfX19leF90YWJsZSA9IC47DQorCSAgICooX19leF90YWJs
ZSkgDQorCSAgIF9fc3RvcF9fX2V4X3RhYmxlID0gLjsNCisJfQ0KIA0KICNpZiBkZWZpbmVkKENP
TkZJR19JQTY0X0dFTkVSSUMpDQogICAvKiBNYWNoaW5lIFZlY3RvciAqLw0KLSAgLiA9IEFMSUdO
KDE2KTsNCi0gIG1hY2h2ZWNfc3RhcnQgPSAuOw0KICAgLm1hY2h2ZWMgOiBBVChBRERSKC5tYWNo
dmVjKSAtIFBBR0VfT0ZGU0VUKQ0KLQl7ICooLm1hY2h2ZWMpIH0NCi0gIG1hY2h2ZWNfZW5kID0g
LjsNCisJeyANCisgIAkgICBtYWNodmVjX3N0YXJ0ID0gLjsNCisJICAgKigubWFjaHZlYykNCisJ
ICAgbWFjaHZlY19lbmQgPSAuOw0KKwl9DQogI2VuZGlmDQogDQotICBfX3N0YXJ0X19fa3N5bXRh
YiA9IC47CS8qIEtlcm5lbCBzeW1ib2wgdGFibGUgKi8NCiAgIF9fa3N5bXRhYiA6IEFUKEFERFIo
X19rc3ltdGFiKSAtIFBBR0VfT0ZGU0VUKQ0KLQl7ICooX19rc3ltdGFiKSB9DQotICBfX3N0b3Bf
X19rc3ltdGFiID0gLjsNCisJeyANCisgIAkgICBfX3N0YXJ0X19fa3N5bXRhYiA9IC47CS8qIEtl
cm5lbCBzeW1ib2wgdGFibGUgKi8NCisJICAgKihfX2tzeW10YWIpIA0KKyAgCSAgIF9fc3RvcF9f
X2tzeW10YWIgPSAuOw0KKwl9DQogDQogICBfX2thbGxzeW1zIDogQVQoQUREUihfX2thbGxzeW1z
KSAtIFBBR0VfT0ZGU0VUKQ0KIAl7DQpAQCAtNzMsMTMgKzc3LDE0IEBADQogCX0NCiANCiAgIC8q
IFVud2luZCBpbmZvICYgdGFibGU6ICovDQotICAuID0gQUxJR04oOCk7DQogICAuSUFfNjQudW53
aW5kX2luZm8gOiBBVChBRERSKC5JQV82NC51bndpbmRfaW5mbykgLSBQQUdFX09GRlNFVCkNCiAJ
eyAqKC5JQV82NC51bndpbmRfaW5mbyopIH0NCi0gIGlhNjRfdW53X3N0YXJ0ID0gLjsNCiAgIC5J
QV82NC51bndpbmQgOiBBVChBRERSKC5JQV82NC51bndpbmQpIC0gUEFHRV9PRkZTRVQpDQotCXsg
KiguSUFfNjQudW53aW5kKikgfQ0KLSAgaWE2NF91bndfZW5kID0gLjsNCisJeyANCisJICAgaWE2
NF91bndfc3RhcnQgPSAuOw0KKwkgICAqKC5JQV82NC51bndpbmQqKQ0KKwkgICBpYTY0X3Vud19l
bmQgPSAuOw0KKwl9DQogDQogICAucm9kYXRhIDogQVQoQUREUigucm9kYXRhKSAtIFBBR0VfT0ZG
U0VUKQ0KIAl7ICooLnJvZGF0YSkgKigucm9kYXRhLiopIH0NCkBAIC05OCwyMyArMTAzLDI4IEBA
DQogICAuaW5pdC5kYXRhIDogQVQoQUREUiguaW5pdC5kYXRhKSAtIFBBR0VfT0ZGU0VUKQ0KIAl7
ICooLmluaXQuZGF0YSkgfQ0KIA0KLSAgX19pbml0cmFtZnNfc3RhcnQgPSAuOw0KICAgLmluaXQu
cmFtZnMgOiBBVChBRERSKC5pbml0LnJhbWZzKSAtIFBBR0VfT0ZGU0VUKQ0KLQl7ICooLmluaXQu
cmFtZnMpIH0NCi0gIF9faW5pdHJhbWZzX2VuZCA9IC47DQorCXsgDQorICAJICAgX19pbml0cmFt
ZnNfc3RhcnQgPSAuOw0KKwkgICAqKC5pbml0LnJhbWZzKQ0KKwkgICBfX2luaXRyYW1mc19lbmQg
PSAuOw0KKwl9DQogDQotICAgLiA9IEFMSUdOKDE2KTsNCi0gIF9fc2V0dXBfc3RhcnQgPSAuOw0K
ICAgLmluaXQuc2V0dXAgOiBBVChBRERSKC5pbml0LnNldHVwKSAtIFBBR0VfT0ZGU0VUKQ0KLSAg
ICAgICAgeyAqKC5pbml0LnNldHVwKSB9DQotICBfX3NldHVwX2VuZCA9IC47DQotICBfX3N0YXJ0
X19fcGFyYW0gPSAuOw0KKwl7IA0KKwkgICBfX3NldHVwX3N0YXJ0ID0gLjsNCisJICAgKiguaW5p
dC5zZXR1cCkNCisJICAgX19zZXR1cF9lbmQgPSAuOw0KKwl9DQogICBfX3BhcmFtIDogQVQoQURE
UihfX3BhcmFtKSAtIFBBR0VfT0ZGU0VUKQ0KLSAgICAgICAgeyAqKF9fcGFyYW0pIH0NCi0gIF9f
c3RvcF9fX3BhcmFtID0gLjsNCi0gIF9faW5pdGNhbGxfc3RhcnQgPSAuOw0KKwl7IA0KKwkgICBf
X3N0YXJ0X19fcGFyYW0gPSAuOw0KKwkgICAqKF9fcGFyYW0pDQorCSAgIF9fc3RvcF9fX3BhcmFt
ID0gLjsNCisJfQ0KICAgLmluaXRjYWxsLmluaXQgOiBBVChBRERSKC5pbml0Y2FsbC5pbml0KSAt
IFBBR0VfT0ZGU0VUKQ0KIAl7DQorCQlfX2luaXRjYWxsX3N0YXJ0ID0gLjsNCiAJCSooLmluaXRj
YWxsMS5pbml0KQ0KIAkJKiguaW5pdGNhbGwyLmluaXQpDQogCQkqKC5pbml0Y2FsbDMuaW5pdCkN
CkBAIC0xMjIsOCArMTMyLDggQEANCiAJCSooLmluaXRjYWxsNS5pbml0KQ0KIAkJKiguaW5pdGNh
bGw2LmluaXQpDQogCQkqKC5pbml0Y2FsbDcuaW5pdCkNCisJCV9faW5pdGNhbGxfZW5kID0gLjsN
CiAJfQ0KLSAgX19pbml0Y2FsbF9lbmQgPSAuOw0KICAgLiA9IEFMSUdOKFBBR0VfU0laRSk7DQog
ICBfX2luaXRfZW5kID0gLjsNCiANCkBAIC0xMzgsNyArMTQ4LDYgQEANCiAJICBfX3N0b3BfZ2F0
ZV9zZWN0aW9uID0gLjsNCiAJfQ0KIA0KLSAgLiA9IEFMSUdOKFNNUF9DQUNIRV9CWVRFUyk7DQog
ICAuZGF0YS5jYWNoZWxpbmVfYWxpZ25lZCA6IEFUKEFERFIoLmRhdGEuY2FjaGVsaW5lX2FsaWdu
ZWQpIC0gUEFHRV9PRkZTRVQpDQogICAgICAgICB7ICooLmRhdGEuY2FjaGVsaW5lX2FsaWduZWQp
IH0NCiANCg==

------_=_NextPart_001_01C2C3E3.F51450CB--

