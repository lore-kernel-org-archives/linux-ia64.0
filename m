From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 24 Aug 2010 17:51:12 +0000
Subject: Re: [PATCH] guard page for stacks that grow upwards
Message-Id: <AANLkTi=-JRUFH08TYNhB7TyN=YscnNbqwtZ_BwcwKJPS@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4c73f3ed34663af90@agluck-desktop.sc.intel.com>
In-Reply-To: <4c73f3ed34663af90@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org, linux-ia64@vger.kernel.org

Hmm. Looking at the patch a bit more..

On Tue, Aug 24, 2010 at 9:31 AM, Luck, Tony <tony.luck@intel.com> wrote:
>
> +#if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
> + =A0 =A0 =A0 else if (vma->vm_flags & VM_GROWSUP) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 address =3D PAGE_ALIGN(address + 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (address =3D vma->vm_end) {

So I react to two things:

 - that "else" looks wrong. At least conceptually, both could happen -
the code should be entirely able to handle a segment that expands both
ways (which is something that ia64 could do: stack one way, register
spills etc other, all in just one happy vma). I guess we don't set it
up that way now, but the "else" just annoys my sense of aesthetics.
It's an extra four letters that don't add value - just takes it away.

 - The "address =3D PAGE_ALIGN(address + 1);" thing is just ugly.
Wouldn't it be nicer to just move the earlier

  address &=3D PAGE_MASK

back outside the conditionals (and keep the original conditional the
way it was - you only changed it for that bogus "else" case anyway),
and then do

  if (address + PAGE_SIZE =3D vma->vm_end)

rather than have "PAGE_ALIGN(address + 1)" as yet another way of
aligning the address just right.

No?

                              Linus
