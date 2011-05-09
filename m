From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 09 May 2011 22:31:42 +0000
Subject: Re: [PATCH] Don't mlock guardpage if the stack is growing up
Message-Id: <BANLkTim7ATRyJ2NvoCj4Sv=7CLizKMd_WA@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="002354477dba8c26c904a2df68c4"
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.2.00.1105082045250.15552@artax.karlin.mff.cuni.cz>
 <alpine.LSU.2.00.1105081303540.16151@sister.anvils> <alpine.DEB.2.00.1105091307570.32299@artax.karlin.mff.cuni.cz>
 <BANLkTinCUQSjjif3op3H_9HDm5Eu-o+Luw@mail.gmail.com> <BANLkTim3kKJkisZK1mOgKhsEEs7FzZmyXA@mail.gmail.com>
 <1304979549.4865.56.camel@mulgrave.site>
In-Reply-To: <1304979549.4865.56.camel@mulgrave.site>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, Michel Lespinasse <walken@google.com>, Oleg Nesterov <oleg@redhat.com>, linux-ia64@vger.kernel.org

--002354477dba8c26c904a2df68c4
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Mon, May 9, 2011 at 3:19 PM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
>
> So I can test the patch, if you tell me how. =A0I don't use lvm2, so it
> would have to be a simple test case.

Something like the attached. Run it as root (it needs root just for
the mlockall), and see whether the stack it shows changes.

With current kernels, I think the stack expands by one page during the
mlockall (for STACK_GROWSUP), with the patch it shouldn't.

                   Linus

--002354477dba8c26c904a2df68c4
Content-Type: text/x-csrc; charset=US-ASCII; name="t.c"
Content-Disposition: attachment; filename="t.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gnhzk71z0

I2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdHJpbmcuaD4KI2luY2x1ZGUgPHN5cy9tbWFu
Lmg+CgpzdGF0aWMgdm9pZCBzaG93X3N0YWNrKHZvaWQpCnsKCUZJTEUgKm1hcDsKCWNoYXIgYnVm
WzEwMDBdOwoKCW1hcCA9IGZvcGVuKCIvcHJvYy9zZWxmL21hcHMiLCAiciIpOwoJaWYgKCFtYXAp
CgkJcmV0dXJuOwoKCXdoaWxlIChmZ2V0cyhidWYsIDEwMDAsIG1hcCkpIHsKCQlpZiAoIXN0cnN0
cihidWYsICJbc3RhY2tdIikpCgkJCWNvbnRpbnVlOwoJCWZwdXRzKGJ1Ziwgc3Rkb3V0KTsKCX0K
CglmY2xvc2UobWFwKTsKfQoKaW50IG1haW4odm9pZCkKewoJc2hvd19zdGFjaygpOwoJbWxvY2th
bGwoTUNMX0NVUlJFTlQgfCBNQ0xfRlVUVVJFKTsKCXNob3dfc3RhY2soKTsKCXJldHVybiAwOwp9
Cg==
--002354477dba8c26c904a2df68c4--
