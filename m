From: Andreas Schwab <schwab@suse.de>
Date: Tue, 23 Jul 2002 19:17:42 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905824@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

"KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp> writes:

|> On Tue, 23 Jul 2002 14:09:55 +0200
|> Andreas Schwab <schwab@suse.de> wrote:
|>=20
|> > David Mosberger <davidm@napali.hpl.hp.com> writes:
|> >=20
|> > |> ChangeLog
|> > |>=20
|> > |> - Make "xconfig" work again (Keith Owens, Khalid Aziz)
|> > |> - Add HCDP ACPI serial line support (Khalid Aziz)
|> > |> - Drop extraneous set_rte() call from iosapic.c (Alex Williamson)
|> > |> - Fix perfmon SMP initialization ordering bug (Stephane Eranian)
|> > |> - Include perfmon_mckinley.h now that it's public info (Stephane Er=
anian)
|> > |> - Implement pcibios_enable_device for PCI hotplug (Takayoshi Kochi)
|> >=20
|> > Compiling pcihpacpi as module requires acpi_walk_namespace to be
|> > exported from the kernel.
|>=20
|> Excuse me,
|>=20
|> pcihpacpi is an old module that *cannot* do real PCI hotplug and
|> isn't included in 2.4.18 ia64 patch (it's included after 2.4.19-pre2).
|> So don't bother David:)

Sorry, I didn't know that, just wanted to report the fact.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

