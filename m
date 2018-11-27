From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 27 Nov 2018 02:28:14 +0000
Subject: Re: [PATCH] ia64: export node_distance function
Message-Id: <DE5B1FBB-78A1-4DB9-BF3B-F276B84BC0B1@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181103183716.28841-1-mb@lightnvm.io>
In-Reply-To: <20181103183716.28841-1-mb@lightnvm.io>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Correct. Unless you=92d prefer it as a git pull.

Sent from my iPhone

> On Nov 26, 2018, at 18:17, Linus Torvalds <torvalds@linux-foundation.org>=
 wrote:
>=20
>> On Mon, Nov 26, 2018 at 11:27 AM Tony Luck <tony.luck@intel.com> wrote:
>>=20
>> The numa_slit variable used by node_distance is available to a
>> module as long as it is linked at compile-time. However, it is
>> not available to loadable modules. Leading to errors such as:
> [...]
>=20
> Tony: Just checking - you aren't planning on doing a git pull request,
> and want me to apply this directly as a patch?
>=20
>             Linus
