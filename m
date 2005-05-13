From: Andreas Schwab <schwab@suse.de>
Date: Fri, 13 May 2005 20:24:55 +0000
Subject: Re: PATCH: Don't use weak function
Message-Id: <jer7gadgbs.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050513191051.GA29540@lucon.org>
In-Reply-To: <20050513191051.GA29540@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"H. J. Lu" <hjl@lucon.org> writes:

> On Fri, May 13, 2005 at 11:48:35AM -0700, Lu, Hongjiu wrote:
>> Hi David,
>>=20
>> I think it is the result of the usage of weak function. I am enclosing a
>> testcase to show it. The correct approach is to use comdat section group
>> or linkonce section. The problem will go away. I will see if I can come
>> up with a kernel patch.
>>=20
>
> This patch works for me. The key here is the arch dependent file
> has to come before generic one during the final link.

The duplicate functions should not be compiled in the first place.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
