From: "Nuesser, Wilhelm" <wilhelm.nuesser@sap.com>
Date: Fri, 28 Jul 2000 08:06:06 +0000
Subject: [Linux-ia64] Cross compiling problem: relocation truncated to fit ...
Message-Id: <marc-linux-ia64-105590678205239@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

when cross compiling ia64 exec=B4s on an ia32 the cross-ld states
=09
/usr/cross/lib/gcc-lib/ia64-gnu-linux-gnu/2.9-ia64-000216-final/crtbegin.o(.
fini+0x2): relocation truncated to fit: PCREL21B fini
This is reproduceable. When making the same - admittedly quite huge - exec
on an ia64 natively the make works
fine.

Any ideas? Just a stupid setup problem?

Thanks in advance

Willi

------------------
Willi N=FC=DFer
SAP LinuxLab
wilhelm.nuesser@sap.com


