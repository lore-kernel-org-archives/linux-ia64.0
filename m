From: Francis Galiegue <fg@mandrakesoft.com>
Date: Tue, 27 Feb 2001 10:22:38 +0000
Subject: Re: [Linux-ia64] Compiling 2.4.2
Message-Id: <marc-linux-ia64-105590693005217@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005211@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005211@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Mon, 26 Feb 2001, Josue Emmanuel Amaro wrote:

>
> All,
>
> I am trying to build an IA-64 kernel on a Lion B3 system running SuSE 7.1
 beta.
>
> Attached is the error log.  Any ideas on what is going on??
>

ia64 needs (for now) an external patch in order to compile. The latest
"certified working" patch can be found in /pub/linux/kernel/ports/ia64, ove=
=3D
r
2.4.1, whose name is linux-2.4.1-010131.diff.bz2.

--=20
Francis Galiegue, fg@mandrakesoft.com - Normand et fier de l'=EAtre
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


