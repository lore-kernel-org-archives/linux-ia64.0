From: Goutham Rao <goutham.rao@intel.com>
Date: Tue, 29 Aug 2000 03:56:28 +0000
Subject: Re: [Linux-ia64] Is there a kdb patch for Test7 availiable?
Message-Id: <marc-linux-ia64-105590678205398@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205396@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205396@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,
Using the Pause key will get you into the debugger when the kernel is
compiled with KDB.  To get a back trace, type "bt" at the prompt.  Type
"help" to get a full list of commands.

Thanks
Goutham


On Mon, 28 Aug 2000, Broadfoot, KenX wrote:

>=20
> I have 2.4.0-test7 with the ia64 patch...
>=20
> I don't know how to make the built in KDB work... is it broken and is the=
re
> a patch?
>=20
> If it works fine, what is the keystroke for viewing a stack trace?
>=20
> thanks in advance...
>=20
> --ken
>=20
>=20
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
>=20



From plotin!plotin.vortex.de!j_gittinger@isc.lf.net Tue Aug 29 02:32:57 20=
00
Received: from isc.lf.net ([194.64.4.1])
	by mail2.valinux.com with esmtp (Exim 3.16 #1 (Debian))
	id 13ThlI-0006UX-00
	for <linux-ia64@linuxia64.org>; Tue, 29 Aug 2000 02:32:57 -0700
Received: by isc.LF.net (Smail3.2.0.106/isc.LF.net)
	via LF.net GmbH Internet Services
	via remotehost plotin with uucp
	for lists.linuxia64.org
	id m13ThlG-000UrPC; Tue, 29 Aug 2000 11:32:54 +0200 (CEST)
Received:  by plotin.vortex.de (UUPC/extended 1.12b_vortex);
           Tue, 29 Aug 2000 11:20:21 CES
From: "Joerg Gittinger" <j_gittinger@vortex.de>
Message-ID: <39ab8055.plotin@plotin.vortex.de>
To: linux-ia64@linuxia64.org
Date: Tue, 29 Aug 2000 11:17:24 +0200
MIME-Version: 1.0
Content-type: text/plain; charset=3DISO-8859-1
Content-transfer-encoding: Quoted-printable
Priority: normal
X-mailer: Pegasus Mail for Win32 (v3.01d)
Subject: [Linux-ia64] cross compile (assembler) error: Unknown pseudo-op:  =
`.spillsp'
Sender: linux-ia64-admin@linuxia64.org
Errors-To: linux-ia64-admin@linuxia64.org
X-BeenThere: linux-ia64@linuxia64.org
X-Mailman-Version: 2.0beta5
Precedence: bulk
List-Id: Linux Kernel Discussions on the IA-64 Platform <linux-ia64.linuxia=
64.org>

Hi,

I have a cross compile environment with the newest (I think) gnopro gcc,gas=
,...=20
tools. When I try to compile a 2.4.0-test4 kernel (+07/28 patch, kdb-test4 =

patch), I get lots of the following assembler error message:

entry.S:1040: Error: Unknown pseudo-op:  `.spillsp'

What is wrong? Can anybody help me?
-------------------------------
J=F6rg Gittinger
ICP vortex Computersysteme GmbH
Research & Development
Konrad-Zuse-Strasse 9
D-74172 Neckarsulm
Mail: j_gittinger@vortex.de
Tel.: +49 7132 9620 0
Fax.: +49 7132 9620 200

