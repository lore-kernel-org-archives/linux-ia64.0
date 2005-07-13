From: david mosberger <dmosberger@gmail.com>
Date: Wed, 13 Jul 2005 04:50:58 +0000
Subject: Re: autocompilation hosed?
Message-Id: <ed5aea43050712215078a868f6@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_991_1621766.1121230258575"
List-Id: <linux-ia64.vger.kernel.org>
References: <ed5aea4305071214283aada0f2@mail.gmail.com>
In-Reply-To: <ed5aea4305071214283aada0f2@mail.gmail.com>
To: linux-ia64@vger.kernel.org

------=_Part_991_1621766.1121230258575
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On 7/12/05, Tony Luck <tony.luck@gmail.com> wrote:
> > I'm also using gcc-4.0.1 by default now.  It basically seems to work
> > (apart from lots of additional annoying warning messages).  There is
> > one oddity: on my zx2000, it doesn't boot anymore without console=3Dtty=
0
> > or console=3DttyS0 arguments.  I'm not sure yet whether that's a
> > compiler-triggered problem or whether something changed in the kernel
> > that's causing this.
>=20
> No ... I saw it too without gcc-4.  See http://tinyurl.com/clzbu where I
> identified the patch that seems to be the cause.

Patch below fixes the problem.  Moral of the story: don't add
"attributed(packed)" lightly!

  --david

------=_Part_991_1621766.1121230258575
Content-Type: text/x-patch; name="pcdp-fix.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="pcdp-fix.diff"

W0lBNjRdIE1ha2UgUENEUCB3b3JrIGFnYWluLgoKTWFyaydzIHBhdGNoIGFkZGVkICJhdHRyaWJ1
dGUoKHBhY2tlZCkpIiBmb3IgcGNkcF91YXJ0LCB3aXRob3V0CmFjY291bnRpbmcgZm9yIHRoZSBm
YWN0IHRoYXQgdGhlIHN0cnVjdHVyZSBkZWZpbml0aW9uIF9yZWxpZWRfIG9uCmltcGxpY2l0IHBh
ZGRpbmcgYnkgNiBieXRlcy4gIEZpeCBpcyB0byBtYWtlIHRoZSBwYWRkaW5nIGV4cGxpY2l0LgoK
U2lnbmVkLW9mZi1ieTogRGF2aWQgTW9zYmVyZ2VyLVRhbmcgPERhdmlkLk1vc2JlcmdlckBhY20u
b3JnPgoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvZmlybXdhcmUvcGNkcC5oIGIvZHJpdmVycy9maXJt
d2FyZS9wY2RwLmgKLS0tIGEvZHJpdmVycy9maXJtd2FyZS9wY2RwLmgKKysrIGIvZHJpdmVycy9m
aXJtd2FyZS9wY2RwLmgKQEAgLTUyLDYgKzUyLDggQEAgc3RydWN0IHBjZHBfdWFydCB7CiAJdTMy
CQkJCWNsb2NrX3JhdGU7CiAJdTgJCQkJcGNpX3Byb2dfaW50ZmM7CiAJdTgJCQkJZmxhZ3M7CisJ
dTE2CQkJCWNvbm91dF9pbmRleDsKKwl1MzIJCQkJcmVzZXJ2ZWQ7CiB9IF9fYXR0cmlidXRlX18o
KHBhY2tlZCkpOwogCiAjZGVmaW5lIFBDRFBfSUZfUENJCTEK
------=_Part_991_1621766.1121230258575--
