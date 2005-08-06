From: Keith Owens <kaos@sgi.com>
Date: Sat, 06 Aug 2005 07:44:44 +0000
Subject: Re: IA-64 : Map PCI Bar into user virtual space from Physical address Bar[2]
Message-Id: <11479.1123314284@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <42F25A72.7030603@ireq.ca>
In-Reply-To: <42F25A72.7030603@ireq.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, 04 Aug 2005 14:12:02 -0400,=20
=3D?ISO-8859-1?Q?Fran=E7ois_Guay?=3D <guay.francois@ireq.ca> wrote:
>I'm working to build a linux kernel module for a PCI card to run on SGI=20
>Altix IA-64
>
>I'm using Kernel 2.6.5-7.145-rt IA-64
>
>I have read the Linux Device Driver Programmers's - Guide - Porting to=20
>SGI Altix Systems, 007-4520-005
>
>I'm using a Linux software package from PLX version 4.4 for linux 2.6
>http://www.plxtech.com/products/tools/software/default.asp
>
>I load the module in the kernel
>In the user side, I have a program to open the device, map the device
>
>My problem actually is that I can not access the Bar[2] address in my=20
>user program after mapped this Bar in my user memory, the PCI Bar[2] memor=
y region

SGI runs a developer program specifically for this type of question.  I
suggest that you try http://www.sgi.com/developers/.

