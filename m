From: Matt Domsch <Matt_Domsch@dell.com>
Date: Sat, 11 Oct 2003 16:11:34 +0000
Subject: Re: [PATCH] select EFI partition support by default
Message-Id: <marc-linux-ia64-106588893114261@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106588409310269@msgid-missing>
In-Reply-To: <marc-linux-ia64-106588409310269@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> +=A0=A0=A0=A0=A0=A0 bool "EFI GUID Partition support" if PARTITION_ADVANC=
ED
> +=A0=A0=A0=A0=A0=A0 default y if !PARTITION_ADVANCED && IA64

Can we make CONFIG_LBD force on CONFIG_EFI_PARTITION too then?
-Matt

--=20
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

