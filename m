From: Brent Casavant <bcasavan@sgi.com>
Date: Wed, 25 Jan 2006 23:09:31 +0000
Subject: RE: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060125170714.W16092@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
In-Reply-To: <20060118163305.Y42462@chenjesu.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, 25 Jan 2006, Brent Casavant wrote:

> Hmm.  I have only scant evidence to go on from the panic output,
> but it looks like "current" (r13) is not equal to the value of "next"
> by the time we get into sn_migrate().  One example run apparently
> has current=E0000030079d8000, next=E000003015990000.

Got it!  We're context switching.  "next" became "current".  No
telling what on earth "next's next" was.  So after calling
ia64_switch_to(next), I have to refer to "current" in order to
access what was "next" before the call.  My brain's all knotted up.

Take 5 following soon.

Brent

--=20
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
