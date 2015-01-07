From: David Binderman <dcb314@hotmail.com>
Date: Wed, 07 Jan 2015 09:52:29 +0000
Subject: ia64/kernel/unwind.c:907: possible ternary operator problem ?
Message-Id: <DUB128-W557B630386C07401576E59C460@phx.gbl>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello there,

[linux-3.19-rc3/arch/ia64/kernel/unwind.c:907]: (style) Same expression in =
both branches of ternary operator.

Source code is

int base =3D (i < 4) ? UNW_REG_F2 : UNW_REG_F16 - 4;

but

=A0=A0=A0 UNW_REG_F2, UNW_REG_F3, UNW_REG_F4, UNW_REG_F5,
=A0=A0=A0 UNW_REG_F16, UNW_REG_F17, UNW_REG_F18, UNW_REG_F19,

so UNW_REG_F16 is only 4 bigger than UNW_REG_F2.

Suggest code rework. Adding some () to make the expression more
clear might also help.

Regards

David Binderman

 		 	   		  