From: Andreas Schwab <schwab@suse.de>
Date: Thu, 05 Jan 2006 22:04:41 +0000
Subject: Re: [PATCH] cleanup XPC disengage related messages (v2)
Message-Id: <jer77mnxfq.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <43AC2281.mailxDCB118CPI@aqua.americas.sgi.com>
In-Reply-To: <43AC2281.mailxDCB118CPI@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Dean Nelson <dcn@sgi.com> writes:

> +		if (xpc_partition_engaged(-1UL)) {
> +			if (jiffies >=3D printmsg_time) {

This should use time_after().

> +			if (!(volatile int) xpc_disengage_request_timedout) {

This cast is useless.  Qualifiers are ignored on non-lvalues.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
