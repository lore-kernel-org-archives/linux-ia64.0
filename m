From: Andreas Schwab <schwab@suse.de>
Date: Fri, 17 Oct 2003 22:40:48 +0000
Subject: Re: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106643054216291@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Luck, Tony" <tony.luck@intel.com> writes:

>> I expect there are probably different opinions about the idea
>> that "dd if=3D/dev/mem" exits without doing anything.  Sparc and
>> 68K have nearby code that bit-buckets writes and returns zeroes
>> for reads of page zero.  We could do that, too, but it seems like
>> kind of a hack, and holes on ia64 can be BIG (on the order of
>> 256GB for one box).
>
> Filling in the holes does seem like a bad idea, but so does returning
> EOF when you hit a hole (which is what I think your patch is doing).
>
> Would ENODEV be better?

EIO would probably fit better.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
