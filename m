From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Thu, 24 Jul 2003 13:53:27 +0000
Subject: RE: a nice way to reboot :-)
Message-Id: <marc-linux-ia64-105905505204446@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105887789030732@msgid-missing>
In-Reply-To: <marc-linux-ia64-105887789030732@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

I think we've beaten this to death: yes, it is an annoying bug, and
deserves to be fixed.

Just to clarify: I think you want to use tar with --exclude=3D/proc or -l;
tar doesn't have an -xdev option (that is for find, used with cpio).
I've also used --exclude-from=3D/nodump where /nodump lists the
directories to skip: /tmp, /proc, /dev, etc.  I actually started
doing that because my IA64 Linux system rebooted when using tar to
backup (several filesystems at once) to tape :-(
Also note that those are GNU tar extension, and are not available
on SysV (but then, I've never seen a SVR4 machine reboot reading /proc).

Andreas, I don't think your analogy is even close: tar is documented
create an archive; shutdown is documented to reboot the system:
what Bruno was saying is that running tar (even on /proc) is no more
expected to reboot the system than doing an "ls" on /proc.
The UnitedLinux man page for tar makes no indication that root can
reboot the system with it...  Even worse, this behavior does not
occur on other Linux/BSD systems, so people don't have a "reasonable
expectation" for it to kill the system, especially when "properly"
invoked.  (Now, trying to extract an old /proc from a tarfile is
different -- I'll believe that attempting to replace /proc could
reasonably be expected to cause problems, but not reading /proc).

Kevin

-----Original Message-----
From: Andreas Schwab [mailto:schwab@suse.de]
Sent: Thursday, July 24, 2003 6:52 AM
To: Bruno Cornec
Cc: Matthew Wilcox; ia64-list; giovanni_pala@hp.com
Subject: Re: a nice way to reboot :-)


Bruno Cornec <Bruno.Cornec@hp.com> writes:

|> I just wonder if this could be used as a DOS from outside the system. In
|> which case, it would be a Bad Thing (tm :-)
|>=20
|> > root can crash
|> > the system any way they want. =20
|>=20
|> Yes, that's true. But it just more surprising when you think you just
|> pass a normal command ;-)

If you are already root then shutdown -h is just as effective.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
