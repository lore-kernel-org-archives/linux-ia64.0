From: Francis Galiegue <fg@mandrakesoft.com>
Date: Wed, 28 Feb 2001 16:29:07 +0000
Subject: Re: [Linux-ia64] Solid hangs with 2.4.1 + 010131 patch + timer bug
Message-Id: <marc-linux-ia64-105590693005222@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005220@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005220@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, 28 Feb 2001, Francis Galiegue wrote:

>=20
> Before I go on and try to track down the bug, I'd like to know whether BI=
OS rev
> and firmware revisions can be in cause... If not I'll go with kdb...
>=20

First result at kdb: with no breakpoint, when the hangs occur, I cannot even
enter kdb anymore...

--=20
Francis Galiegue, fg@mandrakesoft.com - Normand et fier de l'=EAtre
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


