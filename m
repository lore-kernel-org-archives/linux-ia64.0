From: Randy Dunlap <rdunlap@infradead.org>
Date: Thu, 11 Mar 2021 06:30:03 +0000
Subject: Re: [PATCH] ia64: kernel: Few typos fixed in the file fsys.S
Message-Id: <27e24dea-44de-32fc-9e32-f358aa4207e3@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210311061058.29492-1-unixbhaskar@gmail.com>
 <e26a1461-0d05-d79c-7688-de45d285e068@infradead.org>
 <YEm3ubX2Jqu49MwF@Gentoo>
In-Reply-To: <YEm3ubX2Jqu49MwF@Gentoo>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On 3/10/21 10:24 PM, Bhaskar Chowdhury wrote:
> On 22:15 Wed 10 Mar 2021, Randy Dunlap wrote:
>> On 3/10/21 10:10 PM, Bhaskar Chowdhury wrote:
>>>
>>> Mundane spelling fixes.
>>>
>>> Signed-off-by: Bhaskar Chowdhury <unixbhaskar@gmail.com>
>>
>> Acked-by: Randy Dunlap <rdunlap@infradead.org>
>>
>> but no maintainer Cc:ed to pick it up...
>>
> I have seen "maintainer less" files and you have pointed out that too in =
the
> past...what do I do Randy??? Should run "git blame" to find out ,who touc=
h the file and
> include those mail??? I don't think that would be good idea.
>=20
> Bemused!! Throw some light.

Well, we know that ia64 is orphaned, so you need to find someone
to merge the patch. Andrew Morton is usually a good bet. :)

or use 'git log' <filename> to see who has been merging patches
to that file.

>>> ---
>>> =A0arch/ia64/kernel/fsys.S | 4 ++--
>>> =A01 file changed, 2 insertions(+), 2 deletions(-)

--=20
~Randy
