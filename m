From: Andreas Schwab <schwab@suse.de>
Date: Fri, 25 Jan 2002 15:11:58 +0000
Subject: Re: [Linux-ia64] Patch to fix latest kernels issue with FW83
Message-Id: <marc-linux-ia64-105590698805930@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805927@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805927@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"Mallick, Asit K" <asit.k.mallick@intel.com> writes:

|> We have root caused the stability problem with latest kernels and FW83 (=
LION
|> platform). The following patch (based on 2.4.17) fixes the problem. Plea=
se
|> let me know if you still see a problem after applying this patch.

I'm getting an infinite stream of "ia64_log_get: Failed to retrieve
SAL error record type 3", rendering the machine useless.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

