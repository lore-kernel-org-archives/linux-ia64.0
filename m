From: david mosberger <dmosberger@gmail.com>
Date: Mon, 15 Aug 2005 21:52:14 +0000
Subject: updated libunwind kernel patch
Message-Id: <ed5aea4305081514526149997a@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_485_32608522.1124142734955"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

------=_Part_485_32608522.1124142734955
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Attached below is an updated libunwind kernel patch relative to Tony's
linux-2.6 git repository.  On the ia64-side, I just updated it
slightly to account for minor changes in Tony's tree.  There is also
the beginning of some x86-64 support (to demonstrate the portability
of the API), but that code isn't ready for prime-time.  I haven't made
a final decision on what to do about that.  On the one hand, I'd like
to have libunwind support for more than one platform but on the other,
there are some GCC issues which are standing in the way for libunwind
being used as the primary unwinder on DWARF-based platforms (at least
as of last time I checked) so I may still decide to push for an
initial ia64-only version, since that's where we'd get the biggest
benefit (single source tree which can be shared 95% with the
user-level libunwind & lots of bug-fixes compared to the old kernel
unwinder).

  --david
--=20
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536

------=_Part_485_32608522.1124142734955
Content-Type: application/x-gzip; name="libunwind-050815.diff.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="libunwind-050815.diff.gz"


------=_Part_485_32608522.1124142734955--
