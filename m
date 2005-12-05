From: Andreas Schwab <schwab@suse.de>
Date: Mon, 05 Dec 2005 23:46:42 +0000
Subject: Re: Reading /proc/stat is slooow
Message-Id: <jebqzv85ul.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <je1x0v4cpy.fsf@sykes.suse.de>
In-Reply-To: <je1x0v4cpy.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:

> On Fri, Dec 02, 2005 at 06:42:49PM +0100, Andreas Schwab wrote:
>> At some point after 2.6.13 reading /proc/stat has become too slow.  This
>> is most visible with xosview, which spends up to 80% in kernel space.  I
>> have attached a simple program that you can run with "strace -r" to see

Actually I meant to use "strace -T", which displays the time spent _in_
the syscall.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
