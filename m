From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Wed, 10 Jan 2001 03:26:31 +0000
Subject: RE: [Linux-ia64] kernel update (relative to 2.4.0) - copy_user fi
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C07AB5.20704397"
Message-Id: <marc-linux-ia64-105590693005015@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C07AB5.20704397
Content-Type: text/plain;
	charset="ISO-8859-1"

There is one return path in the __copy_user that do not restore the ar.lc
register. This is causing applications that uses ar.lc to fail. Attached is
a patch to fix it (file is also attached).

Thanks,
Asit

--- linux-2.4.0/arch/ia64/lib/copy_user.S       Thu Jan  4 12:50:17 2001
+++ linux/arch/ia64/lib/copy_user.S     Tue Jan  9 05:35:36 2001
@@ -319,6 +319,7 @@
        EX(failure_out,(EPI) st1 [dst1]=val1[PIPE_DEPTH-1],1)
        br.ctop.dptk.few 5b
        ;;
+       mov ar.lc=saved_lc
        mov pr=saved_pr,0xffffffffffff0000
        mov ar.pfs=saved_pfs
        br.ret.dptk.few rp




------_=_NextPart_000_01C07AB5.20704397
Content-Type: application/octet-stream;
	name="copyu.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="copyu.diff"

--- linux-2.4.0/arch/ia64/lib/copy_user.S	Thu Jan  4 12:50:17 2001=0A=
+++ linux/arch/ia64/lib/copy_user.S	Tue Jan  9 05:35:36 2001=0A=
@@ -319,6 +319,7 @@=0A=
 	EX(failure_out,(EPI) st1 [dst1]=3Dval1[PIPE_DEPTH-1],1)=0A=
 	br.ctop.dptk.few 5b=0A=
 	;;=0A=
+	mov ar.lc=3Dsaved_lc=0A=
 	mov pr=3Dsaved_pr,0xffffffffffff0000=0A=
 	mov ar.pfs=3Dsaved_pfs=0A=
 	br.ret.dptk.few rp=0A=

------_=_NextPart_000_01C07AB5.20704397--


