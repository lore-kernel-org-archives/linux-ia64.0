From: Andreas Schwab <schwab@suse.de>
Date: Tue, 02 Apr 2002 07:52:17 +0000
Subject: Re: [Linux-ia64] Basic Advice Needed
Message-Id: <marc-linux-ia64-105590701905360@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905348@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905348@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Jeremy Fox <jerfox@Stanford.EDU> writes:

|> As someone pointed out, the network and SCSI adapters may be causing
|> problems. It has an Adaptec Ultra160 dual channel SCSI card for
|> example, which definitely seems nonstandard.

Passing "swiotlb@96" to the kernel might make it more stable.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

