From: Andreas Schwab <schwab@suse.de>
Date: Tue, 13 May 2003 10:52:36 +0000
Subject: Re: [Linux-ia64] [patch] 2.4.21-rc1 Close rmmod race on ia64
Message-Id: <marc-linux-ia64-105590723705756@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705748@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705748@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@sgi.com> writes:

|> @@ -51,10 +53,11 @@ search_exception_table (unsigned long ad
|>  		fix.cont =3D entry->cont + main_gp;
|>  	return fix;
|>  #else
|> -	struct archdata *archdata;

??? archdata is still needed.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

