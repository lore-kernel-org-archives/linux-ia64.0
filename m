From: Jun Nakajima <jun@sco.com>
Date: Tue, 27 Jun 2000 22:02:09 +0000
Subject: [Linux-ia64] Using f6-f11 floating-point registers
Message-Id: <marc-linux-ia64-105590678205181@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

At this point, the kernel is using more than f6-f11 floating-point
registers (using -mfixed-range=F10-f15,f32-f127, i.e. those are *not*
available to the kernel, but the others, like f16-f31 are).=20

When do we support the reduced FP model (EL_IA_64_REDUCEFP), where only
f6-f11 are used by the kernel? Does the current compiler allow the
kernel to use those FP registers only, if we provide
-mfixed-range=F2-f5,f12-f127, for example? Of course, we need to change
the kernel if we do this.

Thanks,
--=20
Jun U Nakajima
Core OS Development
SCO/Murray Hill, NJ


