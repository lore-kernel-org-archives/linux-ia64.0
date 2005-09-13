From: Keith Owens <kaos@sgi.com>
Date: Tue, 13 Sep 2005 07:27:30 +0000
Subject: Re: 2.6.14-rc1 breaks tg3 on ia64
Message-Id: <25288.1126596450@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Mon, 12 Sep 2005 23:59:37 MST."
             <20050913065937.GA7849@kroah.com> 
References: <22029.1126588937@kao2.melbourne.sgi.com>
In-Reply-To: <22029.1126588937@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Greg KH <greg@kroah.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>

On Mon, 12 Sep 2005 23:59:37 -0700,=20
Greg KH <greg@kroah.com> wrote:
>On Tue, Sep 13, 2005 at 04:17:33PM +1000, Keith Owens wrote:
>> The last time that tg3 broke like this, it was because of the patch
>> below, in 2.6.13-rc6.  That was backed out in 2.6.13-rc7.  Was the PCI
>> patch (or equivalent) reinstated in 2.6.14-rc1?
>>=20
>> From: John W. Linville <linville@tuxdriver.com>
>> Date: Fri, 5 Aug 2005 01:06:10 +0000 (-0700)
>> Subject: [PATCH] PCI: restore BAR values after D3hot->D0 for devices tha=
t need it
>> X-Git-Tag: v2.6.13-rc6
>> X-Git-Url: http://kernel.org/git/?p=3Dlinux/kernel/git/torvalds/linux-2.=
6.git;a=3Dcommitdiff;h=FEc59a711eef002d4ef9eb8de09dd0a26986eb77
>
>So does reverting this patch solve the problem?

I reversing
http://kernel.org/git/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dcomm=
itdiff;h=064b53dbcc977dbf2753a67c2b8fc1c061d74f21,
which appears to be the latest version of this patch.  There was a
patch reject in sparc64, but the common code was reverted.  IA64 (SGI
Altix) with that patch reverted now boots 2.6.14-rc1.

