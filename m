From: "Carron, Thierry" <thierry.carron@hp.com>
Date: Thu, 23 Jan 2003 13:10:14 +0000
Subject: [Linux-ia64] VM strict overcommit on RedHat AS 2.1 kernel 2.4.18-e12 ?
Message-Id: <marc-linux-ia64-105590709805741@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hello,

A customer requires for his internal application a more strict implementati=
on of the VM :
   -> When malloc returns a non-NULL pointer the memory is really available=
 !

How can I obtain this behavior using RedHat  AS 2.1 kernel 2.4.18-e12 ?

I know that Alan Cox has a patch and that a lot of job is currently done in=
 kernel 2.5 .
This patch is partially integrated in the kernel 2.4.18-e12 delivered with =
the RedHat Advanced Server 2.1.=20
But there is a difference between the documentation  about overcommit_memor=
y  in sysctl/vm.txt and the code really implemented in mm/mmap.c
Is there any reason for that ?

Thanks for your help

Thierry CARRON=20
> HP Centre de Comp=E9tence France
* +33 (0).450.094.031



