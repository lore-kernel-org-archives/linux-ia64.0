From: "Hall, Jenna S" <jenna.s.hall@intel.com>
Date: Fri, 25 Jan 2002 17:29:49 +0000
Subject: RE: [Linux-ia64] Patch to fix latest kernels issue with FW83
Message-Id: <marc-linux-ia64-105590698805933@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805927@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805927@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This is yet another symptom of running old firmware.  To avoid this, turn of
"Enable IA-64 Machine Check Abort" under General Setup in your config.

In short, the older firmware releases contain MCA support that is either
broken or nonexistent.  In this case the firmware is falsely reporting
corrected platform errors to the OS, in an endless stream that debilitates
the OS if OS MCA reporting is enabled.

Jenna

-----Original Message-----
From: Andreas Schwab [mailto:schwab@suse.de]
Sent: Friday, January 25, 2002 7:12 AM
To: Mallick, Asit K
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] Patch to fix latest kernels issue with FW83

"Mallick, Asit K" <asit.k.mallick@intel.com> writes:

|> We have root caused the stability problem with latest kernels and FW83
(LION
|> platform). The following patch (based on 2.4.17) fixes the problem.
Please
|> let me know if you still see a problem after applying this patch.

I'm getting an infinite stream of "ia64_log_get: Failed to retrieve
SAL error record type 3", rendering the machine useless.

Andreas.

--
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE GmbH, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

