From: Grant Grundler <grundler@parisc-linux.org>
Date: Mon, 05 Jan 2004 18:33:49 +0000
Subject: [carlos@baldric.uwo.ca: Good news for glibc.]
Message-Id: <20040105183349.GC9004@colo.lackof.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

glibc profiling?
This was originally posted on debian-hppa/parisc-linux mailing lists.

grant

----- Forwarded message from Carlos O'Donell <carlos@baldric.uwo.ca> -----

Old-Return-Path: <carlos@baldric.uwo.ca>
X-Original-To: debian-hppa@lists.debian.org
From: Carlos O'Donell <carlos@baldric.uwo.ca>
To: John David Anglin <dave@hiauly1.hia.nrc.ca>
Cc: parisc-linux@lists.parisc-linux.org,
	debian-hppa@lists.debian.org, lamont@debian.org
Subject: Good news for glibc.
X-Useless-Header: listen, love, accept, mindfullness, patience, and humilit=
y.=20
Resent-Message-ID: <AW1MyC.A.LG.3eQ-_@murphy>
Resent-From: debian-hppa@lists.debian.org
X-Mailing-List: <debian-hppa@lists.debian.org> archive/latest/3162
List-Id: <debian-hppa.lists.debian.org>
List-Post: <mailto:debian-hppa@lists.debian.org>
List-Help: <mailto:debian-hppa-request@lists.debian.org?subject=3Dhelp>
List-Subscribe: <mailto:debian-hppa-request@lists.debian.org?subject=3Dsubs=
cribe>
List-Unsubscribe: <mailto:debian-hppa-request@lists.debian.org?subject=3Dun=
subscribe>
List-Archive: <http://lists.debian.org/debian-hppa/>
Resent-Sender: debian-hppa-request@lists.debian.org
Resent-Date: Mon,  5 Jan 2004 00:44:07 -0600 (CST)
X-Virus-Scanned: by amavisd-new-20030616-p5 (Debian) at lackof.org
X-Spam-Checker-Version: SpamAssassin 2.60 (1.212-2003-09-23-exp) on=20
	colo.lackof.org
X-Spam-Status: No, hits=3D-4.9 required=3D5.0 tests=BAYES_00 autolearn=3Dha=
m=20
	version=3D2.60
X-Spam-Level:=20

On Thu, Jan 01, 2004 at 04:00:16PM -0500, John David Anglin wrote:
> > The main issue was that the 'start' symbol needs to be canonicalized
> > before passing on to the gmon routines. This requires entry.h to be
>=20
> I still think that using __c_f_f_c for this special case is overkill.

What could we use?

Good news, I just fixed LD_PROFILE so I can actually check to see what
functions take up too much time :) I think I inadvertently fixed it for
ia64 too... what do ia64 people use to profile glibc?

c.

A tempting peek! :)

  %   cumulative   self              self     total
 time   seconds   seconds    calls  us/call  us/call  name
  0.00      0.00     0.00    14000     0.00           cfree
  0.00      0.00     0.00     6000     0.00           memset
  0.00      0.00     0.00     2004     0.00           malloc
  0.00      0.00     0.00     2003     0.00           flockfile
  0.00      0.00     0.00     2003     0.00           funlockfile
  0.00      0.00     0.00     2001     0.00           __cxa_finalize
  0.00      0.00     0.00     1002     0.00           index
  0.00      0.00     0.00     1000     0.00           __GI__dl_close
  0.00      0.00     0.00     1000     0.00           __GI__dl_open
  0.00      0.00     0.00     1000     0.00           printf
  0.00      0.00     0.00     1000     0.00           puts
  0.00      0.00     0.00     1000     0.00           strlen
  0.00      0.00     0.00        1     0.00           __libc_start_main
  0.00      0.00     0.00        1     0.00           realloc
  0.00      0.00     0.00        1     0.00           strrchr


--=20
To UNSUBSCRIBE, email to debian-hppa-request@lists.debian.org
with a subject of "unsubscribe". Trouble? Contact listmaster@lists.debian.o=
rg

----- End forwarded message -----
