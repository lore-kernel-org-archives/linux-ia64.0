From: Andreas Schwab <schwab@suse.de>
Date: Wed, 14 Nov 2001 16:45:27 +0000
Subject: Re: [Linux-ia64] correct seg fault address on ia-64??
Message-Id: <marc-linux-ia64-105590698805508@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805506@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805506@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Pereira, D LailaX E" <d.lailax.e.pereira@intel.com> writes:

|>  /* Align to a multiple of page_size, assumed to be a power of two */
|>   x =3D (int *)((long)(((int) (long)x + page_size-1) & ~(page_size-1)));

Never ever cast pointers to int!  Modern C gives you all you need:
uintptr_t.

Andreas.

--=20
Andreas Schwab                                  "And now for something
Andreas.Schwab@suse.de				completely different."
SuSE Labs, SuSE GmbH, Schanz=E4ckerstr. 10, D-90443 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5

