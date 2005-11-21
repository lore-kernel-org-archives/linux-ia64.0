From: Andreas Schwab <schwab@suse.de>
Date: Mon, 21 Nov 2005 21:26:37 +0000
Subject: Re: Fix asm constraint in put_user
Message-Id: <jelkzhofoy.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <je7jb2nigc.fsf@sykes.suse.de>
In-Reply-To: <je7jb2nigc.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

James E Wilson <wilson@tuliptree.org> writes:

> On Mon, 2005-11-21 at 07:12, Andreas Schwab wrote:
>> The st insn on the ia64 does not allow the post-increment to come from a
>> register (only ld does).  Thus the "m" constraint is not suitable for the
>> asm statement in __put_user_size.
>
> You could use the "S" constraint here.  This isn't used anywhere in
> gcc.  This exists solely for use by asms that need a non-postinc MEM.

Alas, it does not work:

sound/oss/rme96xx.c:744: error: 'asm' operand requires impossible reload

That's exactly the place where gcc would like to use a POST_MODIFY with a
register operand.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
