From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Date: Fri, 25 Jul 2014 11:20:39 +0000
Subject: Re: sizeof (struct tYpO *) : it is just a typo or rather a bug ?
Message-Id: <20140725112038.GA401@khazad-dum.debian.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <53D14E60.1010105@gmx.de>
In-Reply-To: <53D14E60.1010105@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>
Cc: linux-ia64@vger.kernel.org, ceph-devel@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu, 24 Jul 2014, Toralf F=F6rster wrote:
> Inspired by this "typo" fix=20
> http://article.gmane.org/gmane.linux.kernel/1754640
> I grep'ed the current git tree of linus for similar issues.

I wonder if we couldn't use Coccinelle to do that?  I would say it would be
not as cool as deep grep magick, but Coccinelle is cool by definition and
therefore immune from any such comparisons :-)

> Nevertheless I was told, that gcc doesn't complain about such things due
> to eventually evaluating it to "sizeof(null)". I'm however curious if at
> least a warning should be emitted in such a case, or?

Well, it cannot become a real bug because the moment the code changes to
actually access/derreference such a typo, it will cause the compiler to
abort with an error.  If gcc will have to waste a measurable amount of time
to issue such a warning, it is not worth it.

OTOH, such typos could confuse someone reading the code into thinking
they're dealing with a different structure or something, and it _is_
incorrect code no matter how harmless, so it makes sense to fix all such
typos eventually.

--=20
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
