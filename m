From: Christoph Lameter <cl@linux-foundation.org>
Date: Thu, 14 Jan 2010 21:59:55 +0000
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-Id: <alpine.DEB.2.00.1001141558260.20895@router.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001140917110.14164@router.home> <20100114182214.GB4545@ldl.fc.hp.com> <84144f021001141117o6271244cmbe9ba790f9616b2c@mail.gmail.com> <20100114203221.GI4545@ldl.fc.hp.com>
 <alpine.DEB.2.00.1001141457250.19915@router.home> <20100114212933.GK4545@ldl.fc.hp.com> <4B4F8D35.5050203@cs.helsinki.fi>
In-Reply-To: <4B4F8D35.5050203@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Alex Chiang <achiang@hp.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org

On Thu, 14 Jan 2010, Pekka Enberg wrote:

> http://git.kernel.org/?p=3Dlinux/kernel/git/penberg/slab-2.6.git;a=3Dcomm=
itdiff;h=FF64d6c42abaffdb8686c77930eafb4da5b676f5

> Maybe your changes are trigger a latent bug with DEFINE_PER_CPU handling =
in
> SLUB?

There is no node -> cpu mapping like that in SLUB.

