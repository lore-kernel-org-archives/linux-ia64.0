From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Thu, 08 Apr 2004 15:54:40 +0000
Subject: syscall_linkage
Message-Id: <407575C0.840593AC@nospam.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Can somebody explain me, please, what the difference is between an
__attribute__((syscall_linkage)) call and a regular one ?

The Itanium Software Conventions & Runtime Architecture Guide does
not say a word about it, does it mean it is a non standard way to
pass parameters ?

What registers need / do not need to be saved with respect to what
is written in the Intel book ?

Thanks,

Zolt=E1n Menyh=E1rt
